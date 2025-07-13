from flask import Flask, render_template_string, request, jsonify
import json
import time
from phoneme_sender import main as process_audio, vibration_map

app = Flask(__name__)

# Store the latest vibration sequence
latest_sequence = []

@app.route('/')
def haptic_interface():
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>HapticSpeak Tester</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: Arial; padding: 20px; background: #f0f0f0; }
            .container { max-width: 500px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
            button { width: 100%; padding: 15px; margin: 10px 0; font-size: 16px; border: none; border-radius: 5px; cursor: pointer; }
            .vibrate-btn { background: #007AFF; color: white; }
            .pattern-btn { background: #34C759; color: white; }
            .sequence-btn { background: #FF9500; color: white; }
            .status { padding: 10px; margin: 10px 0; border-radius: 5px; background: #E3F2FD; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔴 HapticSpeak Tester</h1>
            <div class="status" id="status">Ready to test vibrations</div>
            
            <h3>Test Individual Patterns:</h3>
            <button class="vibrate-btn" onclick="testVibration(200)">Short Pulse (200ms)</button>
            <button class="vibrate-btn" onclick="testVibration(500)">Long Pulse (500ms)</button>
            <button class="pattern-btn" onclick="testPattern([100, 50, 100])">Double Tap</button>
            <button class="pattern-btn" onclick="testPattern([100, 50, 100, 50, 100])">Triple Tap</button>
            <button class="pattern-btn" onclick="testPattern([200, 100, 200, 100, 200])">Heartbeat</button>
            
            <h3>Test Phoneme Vibrations:</h3>
            <button class="sequence-btn" onclick="testPhoneme('AA')">AA (waveform 21)</button>
            <button class="sequence-btn" onclick="testPhoneme('B')">B (waveform 1)</button>
            <button class="sequence-btn" onclick="testPhoneme('T')">T (waveform 2)</button>
            <button class="sequence-btn" onclick="testPhoneme('S')">S (waveform 47)</button>
            
            <h3>Full Audio Processing:</h3>
            <button class="sequence-btn" onclick="processAudio()">Process Audio & Generate Sequence</button>
            <button class="sequence-btn" onclick="playSequence()">Play Full Vibration Sequence</button>
            
            <div id="sequence-info"></div>
        </div>

        <script>
        function updateStatus(message) {
            document.getElementById('status').innerText = message;
        }

        function testVibration(duration) {
            if (navigator.vibrate) {
                navigator.vibrate(duration);
                updateStatus(`Vibrated for ${duration}ms`);
            } else {
                updateStatus('Vibration not supported on this device');
            }
        }

        function testPattern(pattern) {
            if (navigator.vibrate) {
                navigator.vibrate(pattern);
                updateStatus(`Pattern: ${pattern.join('-')}ms`);
            } else {
                updateStatus('Vibration not supported on this device');
            }
        }

        function testPhoneme(phoneme) {
            // Map phoneme to vibration duration based on waveform number
            const phonemeMap = {{ phoneme_map|safe }};
            if (phoneme in phonemeMap) {
                const waveform = phonemeMap[phoneme].waveform;
                const duration = Math.min(waveform * 10, 500); // Scale waveform to duration
                testVibration(duration);
                updateStatus(`Phoneme ${phoneme}: Waveform ${waveform} (${duration}ms)`);
            }
        }

        function processAudio() {
            updateStatus('Processing audio...');
            fetch('/process_audio')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateStatus(`Generated ${data.sequence_length} vibration commands`);
                        document.getElementById('sequence-info').innerHTML = 
                            '<h4>Vibration Sequence:</h4><pre>' + 
                            data.sequence_preview + '</pre>';
                    } else {
                        updateStatus('Error processing audio');
                    }
                });
        }

        function playSequence() {
            updateStatus('Playing vibration sequence...');
            fetch('/play_sequence')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        playVibrationSequence(data.patterns);
                        updateStatus(`Playing ${data.patterns.length} vibration patterns`);
                    } else {
                        updateStatus('No sequence available - process audio first');
                    }
                });
        }

        function playVibrationSequence(patterns) {
            let index = 0;
            function playNext() {
                if (index < patterns.length) {
                    const pattern = patterns[index];
                    const duration = Math.min(pattern.waveform * 10, 500);
                    navigator.vibrate(duration);
                    index++;
                    setTimeout(playNext, duration + 100); // Small gap between vibrations
                }
            }
            playNext();
        }
        </script>
    </body>
    </html>
    ''', phoneme_map=json.dumps(vibration_map))

@app.route('/process_audio')
def process_audio_endpoint():
    try:
        # This would call your existing phoneme processing
        global latest_sequence
        # For demo, create a sample sequence
        latest_sequence = [
            {"phoneme": "OW", "waveform": 37, "library": 1},
            {"phoneme": "V", "waveform": 41, "library": 1},
            {"phoneme": "ER", "waveform": 30, "library": 1},
            {"phoneme": "AO", "waveform": 24, "library": 1},
        ]
        
        sequence_preview = "\\n".join([
            f"{i+1:2d}. {seq['phoneme']} -> W:{seq['waveform']} L:{seq['library']}"
            for i, seq in enumerate(latest_sequence[:10])  # Show first 10
        ])
        
        return jsonify({
            "success": True,
            "sequence_length": len(latest_sequence),
            "sequence_preview": sequence_preview
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

@app.route('/play_sequence')
def play_sequence_endpoint():
    global latest_sequence
    if latest_sequence:
        return jsonify({
            "success": True,
            "patterns": latest_sequence
        })
    else:
        return jsonify({"success": False, "error": "No sequence available"})

if __name__ == '__main__':
    print("🌐 Starting HapticSpeak Web Tester...")
    print("📱 Open this URL on your phone (same network):")
    print("   http://[YOUR_COMPUTER_IP]:5000")
    print("💡 On Android, you can test vibrations directly in the browser")
    app.run(host='0.0.0.0', port=5000, debug=True)