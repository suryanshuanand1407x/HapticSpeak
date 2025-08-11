from pathlib import Path
import json
import re

# Reuse mapping from 61→39 (upper-case ARPAbet phones)
from scripts.data.convert_alignments_to_39 import PHONE_61_TO_39, parse_textgrid_intervals


def process_timit(root: Path, out_root: Path) -> None:
    out_root.mkdir(parents=True, exist_ok=True)
    # Expect TIMIT like: data/timit/TIMIT/*/*/*.PHN (or TextGrid if aligned differently)
    # Here, we parse *.PHN which contain: start end phone (sample indices at 16kHz)
    for phn in root.rglob("*.PHN"):
        with open(phn, "r", encoding="utf-8", errors="ignore") as fh:
            lines = fh.readlines()
        phones = []
        for line in lines:
            parts = line.strip().split()
            if len(parts) != 3:
                continue
            start, end, phone = parts
            phone = phone.lower()
            mapped = PHONE_61_TO_39.get(phone)
            if mapped is None or mapped == "SIL":
                continue
            # Convert sample indices to seconds at 16kHz
            s = int(start) / 16000.0
            e = int(end) / 16000.0
            phones.append({"start": s, "end": e, "phone": mapped})

        if not phones:
            continue
        rel = phn.relative_to(root).with_suffix(".phones.json")
        out_path = out_root / rel
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(phones, indent=2))
        print(f"Wrote {out_path}")


def main():
    timit_root = Path("data/timit/TIMIT")
    out_root = Path("data/processed/timit_phones")
    process_timit(timit_root, out_root)


if __name__ == "__main__":
    main()


