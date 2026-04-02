#!/usr/bin/env bash
# THE AMBER ROOM — Generate 6 Ambient Layers
# Your voiceover is 47 minutes. Layers set to 50 minutes
# so you have room for title card and end card.
# Trim the extra in CapCut.
#
# IMPORTANT: Outputs MP3 directly (no WAV intermediate).
# Fades removed — ffmpeg's afade causes progressive volume decay
# on long files. Add fade in/out in CapCut instead.

set -e
DURATION=3000
RATE=48000

echo ""
echo "══════════════════════════════════════════════"
echo "  THE AMBER ROOM — 6 Ambient Layers"
echo "  Duration: $((DURATION/60)) minutes"
echo "  Each layer exported as MP3 (192kbps CBR)"
echo "══════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════
# LAYER 1: WARM DRONE PAD
# CapCut volume: 22-25%
# A deep warm hum. Like the room itself is breathing.
# ═══════════════════════════════════════════
echo "[1/6] Warm Drone Pad..."
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$DURATION:c=brown:a=0.5" \
  -af "\
lowpass=f=200,\
highpass=f=20,\
equalizer=f=60:t=h:width=40:g=6,\
equalizer=f=100:t=h:width=50:g=4,\
equalizer=f=150:t=h:width=40:g=2,\
volume=2.0" \
  -codec:a libmp3lame -b:a 192k \
  LAYER1_warm_drone.mp3 2>/dev/null
echo "  ✓ LAYER1_warm_drone.mp3 — drag into CapCut at 22-25%"
echo ""

# ═══════════════════════════════════════════
# LAYER 2: RAIN ON WINDOW
# CapCut volume: 20-23%
# Steady gentle rain. The signature Amber Room sound.
# ═══════════════════════════════════════════
echo "[2/6] Rain on Window..."
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$DURATION:c=pink:a=0.5" \
  -af "\
lowpass=f=7000,\
highpass=f=250,\
equalizer=f=600:t=h:width=300:g=-3,\
equalizer=f=2000:t=h:width=600:g=3,\
equalizer=f=4000:t=h:width=800:g=2,\
equalizer=f=5500:t=h:width=600:g=1,\
volume=1.5" \
  -codec:a libmp3lame -b:a 192k \
  LAYER2_rain.mp3 2>/dev/null
echo "  ✓ LAYER2_rain.mp3 — drag into CapCut at 20-23%"
echo ""

# ═══════════════════════════════════════════
# LAYER 3: DISTANT THUNDER
# CapCut volume: 15-18%
# Deep far-away rumbles. Place ONLY in first 60% of timeline.
# ═══════════════════════════════════════════
echo "[3/6] Distant Thunder..."
THUNDER_DUR=$((DURATION * 65 / 100))
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$THUNDER_DUR:c=brown:a=0.6" \
  -af "\
lowpass=f=110,\
highpass=f=12,\
equalizer=f=30:t=h:width=20:g=8,\
equalizer=f=60:t=h:width=30:g=5,\
equalizer=f=90:t=h:width=30:g=3,\
volume=2.0" \
  -codec:a libmp3lame -b:a 192k \
  LAYER3_thunder.mp3 2>/dev/null
echo "  ✓ LAYER3_thunder.mp3 — drag into CapCut at 15-18%"
echo "    IMPORTANT: Place this ONLY from 0:00 to $((THUNDER_DUR/60)) minutes"
echo "    Leave the rest of the timeline empty. Storm passes."
echo ""

# ═══════════════════════════════════════════
# LAYER 4: FIREPLACE CRACKLE
# CapCut volume: 12-15%
# Pops, crackles, ticks. Place ONLY in first 75% of timeline.
# Uses Python for precise event placement via direct PCM mixing.
# ═══════════════════════════════════════════
echo "[4/6] Fireplace Crackle + Room Details..."
FIRE_DUR=$((DURATION * 78 / 100))

python3 << 'PYEOF'
import subprocess, random, os, struct, wave, array

DURATION = 3000
FIRE_DUR = DURATION * 78 // 100
RATE = 48000

# Generate sound samples
subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i", "anoisesrc=d=0.07:c=white:a=0.25",
    "-af", "highpass=f=2800,lowpass=f=10000,afade=t=out:ss=0.02:d=0.05,volume=0.5",
    "-ar", str(RATE), "-ac", "1", "_pop.wav"], capture_output=True)
subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i", "anoisesrc=d=0.14:c=white:a=0.18",
    "-af", "highpass=f=2000,lowpass=f=8000,afade=t=in:ss=0:d=0.02,afade=t=out:ss=0.04:d=0.10,volume=0.4",
    "-ar", str(RATE), "-ac", "1", "_crackle.wav"], capture_output=True)
subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i", "sine=frequency=340:duration=0.30",
    "-af", "tremolo=f=6:d=0.5,volume=0.2,afade=t=in:ss=0:d=0.05,afade=t=out:ss=0.10:d=0.20",
    "-ar", str(RATE), "-ac", "1", "_creak.wav"], capture_output=True)
subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i", "sine=frequency=3600:duration=0.04",
    "-af", "afade=t=out:ss=0.01:d=0.03,volume=0.35",
    "-ar", str(RATE), "-ac", "1", "_tick.wav"], capture_output=True)

events = []
sounds = ["_pop.wav", "_crackle.wav", "_creak.wav", "_tick.wav"]

# Pops: every 6-14 seconds
t = random.randint(3, 8)
while t < FIRE_DUR:
    events.append((t, sounds[0]))
    t += random.randint(6, 14)

# Crackle: every 10-20 seconds
t = random.randint(5, 12)
while t < FIRE_DUR:
    events.append((t, sounds[1]))
    t += random.randint(10, 20)

# Creak: every 40-80 seconds
t = random.randint(25, 50)
while t < FIRE_DUR:
    events.append((t, sounds[2]))
    t += random.randint(40, 80)

# Clock tick: every 25-50 seconds (throughout full duration)
t = random.randint(15, 30)
while t < DURATION - 20:
    events.append((t, sounds[3]))
    t += random.randint(25, 50) if t < DURATION * 0.5 else random.randint(40, 70)

events.sort()
print(f"  Placing {len(events)} fire + detail events via PCM mixing...")

# Read sound samples into memory
sound_cache = {}
for s in sounds:
    with wave.open(s, 'r') as w:
        n = w.getnframes()
        raw = w.readframes(n)
        sound_cache[s] = array.array('h')
        sound_cache[s].frombytes(raw)

# Create output buffer
total_samples = DURATION * RATE
buf = array.array('f', [0.0] * total_samples)

# Mix events directly into buffer
for sec, snd in events:
    start = int(sec * RATE)
    samples = sound_cache[snd]
    end = min(start + len(samples), total_samples)
    for i in range(end - start):
        buf[start + i] += samples[i]

# Normalize to int16
max_val = max(abs(x) for x in buf) or 1.0
scale = 30000.0 / max_val
out = array.array('h', [max(-32768, min(32767, int(x * scale))) for x in buf])

# Write WAV then convert to MP3
with wave.open("_layer4.wav", 'w') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(out.tobytes())

subprocess.run(["ffmpeg", "-y", "-i", "_layer4.wav",
    "-codec:a", "libmp3lame", "-b:a", "192k",
    "LAYER4_fireplace.mp3"], capture_output=True)

# Cleanup
for f in ["_pop.wav", "_crackle.wav", "_creak.wav", "_tick.wav", "_layer4.wav"]:
    try: os.remove(f)
    except: pass

print(f"  ✓ {len(events)} events placed")
PYEOF

echo "  ✓ LAYER4_fireplace.mp3 — drag into CapCut at 12-15%"
echo "    Contains: fire pops + crackle + wood creaks + clock ticks"
echo ""

# ═══════════════════════════════════════════
# LAYER 5: ROOM TONE
# CapCut volume: 10-12%
# Constant subtle hum that fills dead silence
# ═══════════════════════════════════════════
echo "[5/6] Room Tone..."
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$DURATION:c=brown:a=0.06" \
  -af "\
lowpass=f=140,\
highpass=f=15,\
volume=1.0" \
  -codec:a libmp3lame -b:a 192k \
  LAYER5_roomtone.mp3 2>/dev/null
echo "  ✓ LAYER5_roomtone.mp3 — drag into CapCut at 10-12%"
echo ""

# ═══════════════════════════════════════════
# LAYER 6: BINAURAL 4Hz DELTA WAVE
# CapCut volume: 5-6%
# Subliminal sleep induction. Headphones only.
# ═══════════════════════════════════════════
echo "[6/6] Binaural 4Hz Delta Wave..."
ffmpeg -y -f lavfi \
  -i "sine=frequency=100:duration=$DURATION" \
  -f lavfi \
  -i "sine=frequency=104:duration=$DURATION" \
  -filter_complex \
  "[0]volume=0.3[left];\
   [1]volume=0.3[right];\
   [left][right]join=inputs=2:channel_layout=stereo" \
  -codec:a libmp3lame -b:a 192k \
  LAYER6_binaural.mp3 2>/dev/null
echo "  ✓ LAYER6_binaural.mp3 — drag into CapCut at 5-6%"
echo ""

# ═══════════════════════════════════════════
# DONE
# ═══════════════════════════════════════════
echo "══════════════════════════════════════════════"
echo ""
echo "  ✓ ALL 6 LAYERS GENERATED"
echo ""
echo "  Files:"
ls -lh LAYER*.mp3 | awk '{print "    " $NF " (" $5 ")"}'
echo ""
echo "  ══════════════════════════════════════"
echo "  CAPCUT CHEAT SHEET:"
echo "  ══════════════════════════════════════"
echo ""
echo "  Track 1: Your NotebookLM voiceover   → 100%"
echo "  Track 2: LAYER1_warm_drone.mp3       → 22-25%"
echo "  Track 3: LAYER2_rain.mp3             → 20-23%"
echo "  Track 4: LAYER3_thunder.mp3          → 15-18%"
echo "           ⚠ FIRST 60% OF TIMELINE ONLY"
echo "  Track 5: LAYER4_fireplace.mp3        → 12-15%"
echo "           (fire fades at 75%, ticks continue)"
echo "  Track 6: LAYER5_roomtone.mp3         → 10-12%"
echo "  Track 7: LAYER6_binaural.mp3         → 5-6%"
echo ""
echo "  NOTE: Add fade in (10s) / fade out (25s) in CapCut"
echo "  for each layer. The ffmpeg afade filter causes volume"
echo "  decay on long files, so fades are handled in CapCut."
echo ""
echo "  IF TOO QUIET: increase by 3-5% each"
echo "  IF TOO LOUD:  decrease by 3-5% each"
echo "  VOICE MUST ALWAYS BE CLEARLY DOMINANT"
echo ""
echo "  TIMELINE:"
echo "  0:00 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ END"
echo "  Voice ████████████████████████████████"
echo "  Drone ████████████████████████████████"
echo "  Rain  ████████████████████████████████"
echo "  Thunder ████████████████░░░░░░░░░░░░░░"
echo "  Fire  ██████████████████████░░░░░░░░░░"
echo "  Room  ████████████████████████████████"
echo "  Bnarl ████████████████████████████████"
echo ""
echo "  ██ = playing  ░░ = silent (layer ended)"
echo ""
echo "══════════════════════════════════════════════"
