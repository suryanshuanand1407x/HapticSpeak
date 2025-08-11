import subprocess
from pathlib import Path


def run_mfa_align(corpus_dir: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    # Requires MFA installed and english_mfa acoustic model + dictionary downloaded
    # mfa download acoustic english_mfa
    # mfa download dictionary english_mfa
    cmd = [
        "mfa", "align",
        str(corpus_dir),
        "english_mfa",
        "english_mfa",
        str(output_dir),
        "--clean",
    ]
    print("Running MFA alignment...")
    subprocess.run(cmd, check=True)
    print("MFA alignment complete.")


def main() -> None:
    corpus_dir = Path("data/librispeech/corpus")
    output_dir = Path("data/librispeech/aligned")
    run_mfa_align(corpus_dir, output_dir)


if __name__ == "__main__":
    main()


