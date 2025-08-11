from pathlib import Path
import json
import pytest

from scripts.data.convert_alignments_to_39 import PHONE_61_TO_39


def test_phone_mapping_basic_vowels():
    assert PHONE_61_TO_39['iy'] == 'IY'
    assert PHONE_61_TO_39['ih'] == 'IH'
    assert PHONE_61_TO_39['eh'] == 'EH'
    assert PHONE_61_TO_39['aa'] == 'AA'


def test_phone_mapping_consonants():
    assert PHONE_61_TO_39['p'] == 'P'
    assert PHONE_61_TO_39['t'] == 'T'
    assert PHONE_61_TO_39['k'] == 'K'
    assert PHONE_61_TO_39['b'] == 'B'
    assert PHONE_61_TO_39['d'] == 'D'
    assert PHONE_61_TO_39['g'] == 'G'


def test_silence_skipped_in_training():
    # Ensure mapping exists but we plan to skip SIL in training label creation
    assert PHONE_61_TO_39['sil'] == 'SIL'


