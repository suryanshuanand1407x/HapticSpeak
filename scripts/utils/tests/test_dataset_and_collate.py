from pathlib import Path
import json
import numpy as np
import torch

from scripts.utils.phoneme_dataset import (
    PhonemeJsonDataset,
    phoneme_collate_fn,
)


def _write_dummy_sample(tmpdir: Path):
    audio_dir = tmpdir / "audio"
    phone_dir = tmpdir / "phones"
    audio_dir.mkdir(parents=True, exist_ok=True)
    phone_dir.mkdir(parents=True, exist_ok=True)

    # Create a fake WAV via librosa tone export would require soundfile; instead
    # we store a small .wav placeholder and skip actual audio load by mocking in real runs.
    # For the unit test, we'll create a minimal manifest and a phone JSON.
    wav_path = audio_dir / "dummy.wav"
    # Minimal 0-length file still triggers librosa failure; so we avoid __getitem__ audio load here.
    # We'll instead only test collate behavior by mocking dataset entries directly.
    wav_path.write_bytes(b"RIFF0000WAVEfmt ")

    phones_path = phone_dir / "dummy.phones.json"
    phones = [{"start": 0.0, "end": 0.1, "phone": "AA"}, {"start": 0.1, "end": 0.2, "phone": "T"}]
    phones_path.write_text(json.dumps(phones))

    manifest = [{"audio_path": str(wav_path), "phones_path": str(phones_path)}]
    manifest_path = tmpdir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest))
    return manifest_path


def test_collate_shapes(tmp_path: Path, monkeypatch):
    manifest_path = _write_dummy_sample(tmp_path)

    # Monkeypatch mel loader to avoid touching real audio stack
    monkeypatch.setattr(
        'scripts.utils.phoneme_dataset.load_mel_spectrogram',
        lambda *args, **kwargs: np.zeros((80, 100), dtype=np.float32),
        raising=True,
    )

    ds = PhonemeJsonDataset(manifest_path, max_frames=100)
    batch = [ds[0], ds[0]]
    out = phoneme_collate_fn(batch)

    assert out['mels'].shape == (2, 80, 100)
    assert out['mel_lens'].tolist() == [100, 100]
    assert out['phone_lens'].shape[0] == 2


