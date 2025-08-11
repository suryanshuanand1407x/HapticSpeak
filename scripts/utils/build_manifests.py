from pathlib import Path
import json


def build_manifest_from_phones(phone_root: Path, audio_root: Path, out_manifest: Path) -> None:
    """Create a training manifest mapping audio to 39-phone sequences.

    Manifest entry example:
      {
        "audio_path": "data/librispeech/LibriSpeech/train-clean-100/19/198/19-198-0000.wav",
        "phones_path": "data/processed/librispeech_phones/19/198/19-198-0000.phones.json"
      }
    """
    entries = []
    for phones_json in phone_root.rglob("*.phones.json"):
        rel = phones_json.relative_to(phone_root).with_suffix("")
        # Recover original wav path from typical LibriSpeech naming
        parts = list(rel.parts)
        if len(parts) < 3:
            continue
        speaker, chapter, base = parts[-3], parts[-2], parts[-1]
        wav = audio_root / "LibriSpeech" / "train-clean-100" / speaker / chapter / f"{base}.wav"
        if not wav.exists():
            # Also check dev-clean
            wav = audio_root / "LibriSpeech" / "dev-clean" / speaker / chapter / f"{base}.wav"
        if not wav.exists():
            continue
        entries.append({
            "audio_path": str(wav).replace("\\", "/"),
            "phones_path": str(phones_json).replace("\\", "/")
        })

    out_manifest.parent.mkdir(parents=True, exist_ok=True)
    out_manifest.write_text(json.dumps(entries, indent=2))
    print(f"Wrote manifest with {len(entries)} items → {out_manifest}")


def main() -> None:
    phone_root = Path("data/processed/librispeech_phones")
    audio_root = Path("data/librispeech")
    out_manifest = Path("data/processed/manifests/train_librispeech_39.json")
    build_manifest_from_phones(phone_root, audio_root, out_manifest)


if __name__ == "__main__":
    main()


