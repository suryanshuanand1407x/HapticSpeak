📄 README.md

# 🔊 HapticSpeak Prototype (Speaker-Based)

This is a prototype for **HapticSpeak** — a system that converts real-time **spoken audio** into **phoneme sequences**, which are then mapped to **audible sound feedback** (for now, using your device speakers instead of a haptic motor).

---

## 🚀 Features

- 🎤 Records live speech via microphone
- 🧠 Uses OpenAI Whisper to transcribe speech to text
- 🔤 Converts text to **ARPAbet phonemes** using `phonemizer`
- 🔊 Plays a unique sound (e.g., WAV file) for each phoneme via speakers
- ✅ Ready for ESP32/Nicla integration with DRV2605L for real vibration output

---

## 📁 Folder Structure

project/
├── phoneme_sender.py              # Main script for recording, decoding, and playing
├── requirements.txt               # Python dependencies
├── README.md                      # This file
├── phoneme_sounds/               # Folder with WAV files like AH.wav, B.wav, etc.
│   ├── AH.wav
│   ├── B.wav
│   ├── S.wav
│   └── …

---

## ⚙️ Setup Instructions

### 1. Create and Activate Virtual Environment

```bash
python -m venv venv
source venv/bin/activate     # macOS/Linux
venv\Scripts\activate        # Windows

2. Install Dependencies

pip install -r requirements.txt

⚠ If you face issues with pyaudio, see the Troubleshooting section below.

⸻

▶️ Running the Project
	1.	Place WAV files for each phoneme inside phoneme_sounds/ folder
(e.g., AH.wav, B.wav, K.wav, etc.)
	2.	Run the script:

python phoneme_sender.py

	3.	Speak into your microphone when prompted

⸻

🛠️ Dependencies

See requirements.txt, which includes:
	•	openai-whisper – Speech-to-text
	•	phonemizer – Text-to-phoneme (ARPAbet)
	•	pyaudio – Microphone input
	•	simpleaudio – WAV playback
	•	torch, ffmpeg-python – Backend requirements for Whisper

⸻

🧩 Troubleshooting

❌ Pyaudio won’t install?

Windows:
	•	Download .whl from here
	•	Install with:

pip install PyAudio‑0.2.11‑cp39‑cp39‑win_amd64.whl



macOS:

brew install portaudio
pip install pyaudio

Ubuntu/Debian:

sudo apt install portaudio19-dev
pip install pyaudio


⸻

🧠 What’s Next?
	•	Replace sound playback with serial transmission to ESP32/Nicla Voice
	•	Trigger real haptic patterns on DRV2605L using phoneme-to-vibration mapping
	•	Optimize latency and accuracy for real-time usage

⸻

👤 Author

Suryanshu Anand
HapticSpeak Project – July 2025

---

Let me know if you'd like this exported as a `.zip` bundle including the WAV generator or a GitHub-ready folder structure.
