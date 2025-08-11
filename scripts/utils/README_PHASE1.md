# Phase 1 — Data Prep & Alignment

This phase prepares datasets and phoneme labels for ML training.

## Steps

1) Install dependencies

```
pip install -r requirements.txt
```

Also install MFA binaries per their docs, then download the English acoustic model and dictionary:

```
mfa download acoustic english_mfa
mfa download dictionary english_mfa
```

2) Download LibriSpeech (train-clean-100, dev-clean)

```
python scripts/data/download_librispeech.py
```

3) Prepare MFA corpus from LibriSpeech

```
python scripts/data/prepare_mfa_corpus.py
```

4) Run MFA alignment (phones)

```
python scripts/data/run_mfa_align.py
```

5) Convert MFA outputs to 39-phone inventory

```
python scripts/data/convert_alignments_to_39.py
```

6) (Optional) Process TIMIT to 39-phone labels for validation

Place TIMIT under `data/timit/TIMIT`, then:

```
python scripts/data/process_timit_39.py
```

Outputs will be under `data/processed/{librispeech_phones,timit_phones}` as JSON with phone, start, end.

## Notes
- Phones are mapped to the standard 39-phone set. Silences are dropped for training labels.
- Audio is expected at 16 kHz mono. Conversion is handled during corpus prep.
- You can now build training manifests from `data/processed/*` for the training phase.
