import os
import sys
import tarfile
import urllib.request
from pathlib import Path

LIBRISPEECH_URLS = {
    "train-clean-100": "https://www.openslr.org/resources/12/train-clean-100.tar.gz",
    "dev-clean": "https://www.openslr.org/resources/12/dev-clean.tar.gz",
}


def download(url: str, target_path: Path) -> None:
    target_path.parent.mkdir(parents=True, exist_ok=True)
    if target_path.exists():
        print(f"Already downloaded: {target_path}")
        return
    print(f"Downloading {url} → {target_path} ...")
    with urllib.request.urlopen(url) as response, open(target_path, "wb") as out_file:
        out_file.write(response.read())
    print("Download complete.")


def extract(archive_path: Path, dest_dir: Path) -> None:
    print(f"Extracting {archive_path} → {dest_dir} ...")
    with tarfile.open(archive_path, "r:gz") as tar:
        tar.extractall(path=dest_dir)
    print("Extraction complete.")


def main() -> None:
    root = Path("data/librispeech")
    archives = root / "archives"
    archives.mkdir(parents=True, exist_ok=True)

    for key, url in LIBRISPEECH_URLS.items():
        archive_path = archives / f"{key}.tar.gz"
        dest_dir = root
        try:
            download(url, archive_path)
            extract(archive_path, dest_dir)
        except Exception as e:
            print(f"Error handling {key}: {e}")
            sys.exit(1)

    print("LibriSpeech train-clean-100 and dev-clean are ready under data/librispeech.")


if __name__ == "__main__":
    main()


