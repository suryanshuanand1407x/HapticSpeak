from __future__ import annotations

from pathlib import Path
from typing import Dict, List, Tuple

import json
import numpy as np
import torch
from torch.utils.data import Dataset
import librosa


PHONES_39_WITH_BLANK = [
    'AA', 'AE', 'AH', 'AO', 'AW', 'AY', 'EH', 'ER', 'EY', 'IH',
    'IY', 'OW', 'OY', 'UH', 'UW', 'B', 'CH', 'D', 'DH', 'F',
    'G', 'HH', 'JH', 'K', 'L', 'M', 'N', 'NG', 'P', 'R',
    'S', 'SH', 'T', 'TH', 'V', 'W', 'Y', 'Z', 'ZH', '<blank>'
]

PHONE_TO_IDX: Dict[str, int] = {p: i for i, p in enumerate(PHONES_39_WITH_BLANK)}
IDX_TO_PHONE: Dict[int, str] = {i: p for p, i in PHONE_TO_IDX.items()}


def load_mel_spectrogram(wav_path: Path, sample_rate: int = 16000,
                         n_mels: int = 80, hop_length: int = 160,
                         win_length: int = 400) -> np.ndarray:
    audio, sr = librosa.load(str(wav_path), sr=sample_rate, mono=True)
    mel = librosa.feature.melspectrogram(
        y=audio, sr=sr, n_mels=n_mels,
        hop_length=hop_length, win_length=win_length
    )
    mel_db = librosa.power_to_db(mel, ref=np.max)
    return mel_db.astype(np.float32)


class PhonemeJsonDataset(Dataset):
    """Dataset that reads a manifest of audio paths and phoneme JSON labels.

    Each phoneme JSON contains items with {"start", "end", "phone"} in seconds.
    We convert phones to indices (39-phone + blank), and produce mel spectrograms.
    """

    def __init__(self, manifest_path: Path, max_frames: int = 1600) -> None:
        self.manifest_path = Path(manifest_path)
        self.max_frames = max_frames
        self.entries = json.loads(self.manifest_path.read_text())

    def __len__(self) -> int:
        return len(self.entries)

    def __getitem__(self, idx: int):
        entry = self.entries[idx]
        wav_path = Path(entry['audio_path'])
        phones_path = Path(entry['phones_path'])

        mel = load_mel_spectrogram(wav_path)
        mel = self._pad_or_truncate(mel, self.max_frames)

        phones = json.loads(phones_path.read_text())
        phone_seq = [PHONE_TO_IDX[p['phone']] for p in phones if p['phone'] in PHONE_TO_IDX]
        phone_seq_tensor = torch.tensor(phone_seq, dtype=torch.long)

        mel_tensor = torch.from_numpy(mel)  # (80, T)
        return {
            'mel': mel_tensor,
            'phones': phone_seq_tensor,
            'mel_len': mel_tensor.shape[1],
            'phones_len': len(phone_seq)
        }

    @staticmethod
    def _pad_or_truncate(mel: np.ndarray, max_frames: int) -> np.ndarray:
        if mel.shape[1] > max_frames:
            return mel[:, :max_frames]
        if mel.shape[1] < max_frames:
            pad = np.zeros((mel.shape[0], max_frames - mel.shape[1]), dtype=mel.dtype)
            return np.concatenate([mel, pad], axis=1)
        return mel


def phoneme_collate_fn(batch: List[dict]):
    mels = [b['mel'] for b in batch]
    phones = [b['phones'] for b in batch]

    max_len = max(m.shape[1] for m in mels)
    mels_padded = []
    for m in mels:
        if m.shape[1] < max_len:
            pad = torch.zeros((m.shape[0], max_len - m.shape[1]), dtype=m.dtype)
            m = torch.cat([m, pad], dim=1)
        mels_padded.append(m)

    mels_tensor = torch.stack(mels_padded)  # (B, 80, T)
    phone_lens = torch.tensor([len(p) for p in phones], dtype=torch.long)
    mel_lens = torch.tensor([m.shape[1] for m in mels_padded], dtype=torch.long)

    return {
        'mels': mels_tensor,
        'phones': phones,
        'mel_lens': mel_lens,
        'phone_lens': phone_lens,
    }


