import os
import shutil
from pathlib import Path
import soundfile as sf
import subprocess


def flac_to_wav(src_flac: Path, dst_wav: Path) -> None:
    dst_wav.parent.mkdir(parents=True, exist_ok=True)
    # Use ffmpeg for robust conversion
    subprocess.run([
        "ffmpeg", "-y", "-i", str(src_flac), "-ac", "1", "-ar", "16000", str(dst_wav)
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)


def prepare_librispeech_for_mfa(librispeech_root: Path, mfa_corpus_root: Path) -> None:
    """Create MFA corpus structure: corpus/speaker/utt.wav and utt.lab with transcript."""
    mfa_corpus_root.mkdir(parents=True, exist_ok=True)

    # LibriSpeech structure: LibriSpeech/<split>/<speaker>/<chapter>/*.flac and *.txt
    for split in ["LibriSpeech/train-clean-100", "LibriSpeech/dev-clean"]:
        split_dir = librispeech_root / split
        if not split_dir.exists():
            print(f"Skip missing split: {split_dir}")
            continue
        for speaker_dir in split_dir.iterdir():
            if not speaker_dir.is_dir():
                continue
            for chapter_dir in speaker_dir.iterdir():
                if not chapter_dir.is_dir():
                    continue
                # Read chapter-level transcript file mapping utt-id → text
                trans_map = {}
                for f in chapter_dir.glob("*.txt"):
                    with open(f, "r", encoding="utf-8") as fh:
                        for line in fh:
                            parts = line.strip().split(" ")
                            utt_id = parts[0]
                            text = " ".join(parts[1:])
                            trans_map[utt_id] = text

                for flac_path in chapter_dir.glob("*.flac"):
                    utt_id = flac_path.stem
                    text = trans_map.get(utt_id, "")
                    if not text:
                        continue

                    speaker = speaker_dir.name
                    dst_dir = mfa_corpus_root / speaker
                    dst_dir.mkdir(parents=True, exist_ok=True)

                    wav_path = dst_dir / f"{utt_id}.wav"
                    lab_path = dst_dir / f"{utt_id}.lab"

                    try:
                        flac_to_wav(flac_path, wav_path)
                        with open(lab_path, "w", encoding="utf-8") as lf:
                            lf.write(text + "\n")
                    except Exception as e:
                        print(f"Failed to convert {flac_path}: {e}")


def main() -> None:
    librispeech_root = Path("data/librispeech")
    mfa_corpus_root = Path("data/librispeech/corpus")
    prepare_librispeech_for_mfa(librispeech_root, mfa_corpus_root)
    print("Prepared MFA corpus at data/librispeech/corpus")


if __name__ == "__main__":
    main()


