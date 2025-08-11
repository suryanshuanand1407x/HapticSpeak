from pathlib import Path
import json
import re


# TIMIT/MFA phones to 39-phone inventory (ARPAbet upper-case)
PHONE_61_TO_39 = {
    # Vowels
    'iy': 'IY', 'ih': 'IH', 'eh': 'EH', 'ey': 'EY', 'ae': 'AE',
    'aa': 'AA', 'aw': 'AW', 'ay': 'AY', 'ah': 'AH', 'ao': 'AO',
    'oy': 'OY', 'ow': 'OW', 'uh': 'UH', 'uw': 'UW', 'er': 'ER',
    'ax': 'AH', 'ix': 'IH', 'ux': 'UW', 'axr': 'ER', 'ax-h': 'AH',

    # Stops
    'p': 'P', 't': 'T', 'k': 'K', 'b': 'B', 'd': 'D', 'g': 'G',
    'dx': 'D', 'td': 'T', 'q': 'K',

    # Fricatives
    'f': 'F', 'v': 'V', 'th': 'TH', 'dh': 'DH', 's': 'S', 'z': 'Z',
    'sh': 'SH', 'zh': 'ZH', 'hh': 'HH', 'hv': 'HH',

    # Affricates
    'ch': 'CH', 'jh': 'JH',

    # Nasals
    'm': 'M', 'n': 'N', 'ng': 'NG', 'em': 'M', 'en': 'N', 'eng': 'NG',

    # Liquids/Glides
    'l': 'L', 'r': 'R', 'w': 'W', 'y': 'Y', 'el': 'L',

    # Silence
    'sil': 'SIL', 'sp': 'SIL', 'spn': 'SIL', 'pau': 'SIL'
}


def parse_textgrid_intervals(text: str):
    """Very simple TextGrid tier interval parser for phone tiers."""
    # This is not a full TextGrid parser, but enough for MFA outputs.
    # Looks for entries like: intervals [n]: xmin = a; xmax = b; text = "ph"
    entries = []
    interval_re = re.compile(r"intervals \[\d+\]:\s*xmin = ([0-9.]+)\s*xmax = ([0-9.]+)\s*text = \"(.*?)\"", re.S)
    for m in interval_re.finditer(text):
        start = float(m.group(1))
        end = float(m.group(2))
        label = m.group(3).strip()
        entries.append((start, end, label))
    return entries


def convert_textgrid_to_39(textgrid_path: Path):
    content = textgrid_path.read_text(encoding="utf-8", errors="ignore")
    intervals = parse_textgrid_intervals(content)

    phones = []
    for start, end, ph in intervals:
        ph_l = ph.lower()
        if ph_l == "":
            continue
        mapped = PHONE_61_TO_39.get(ph_l)
        if mapped is None:
            # Unknown labels are skipped
            continue
        if mapped == "SIL":
            # Optionally skip silences for training labels
            continue
        phones.append({"start": start, "end": end, "phone": mapped})
    return phones


def main():
    aligned_dir = Path("data/librispeech/aligned")
    out_dir = Path("data/processed/librispeech_phones")
    out_dir.mkdir(parents=True, exist_ok=True)

    for tg in aligned_dir.rglob("*.TextGrid"):
        phones = convert_textgrid_to_39(tg)
        if not phones:
            continue
        rel = tg.relative_to(aligned_dir).with_suffix(".phones.json")
        out_path = out_dir / rel
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(phones, indent=2))
        print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()


