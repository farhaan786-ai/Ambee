#!/usr/bin/env bash
# THE AMBER ROOM — Generate 6 Ambient Layers
# Your voiceover is 47 minutes. Layers set to 50 minutes
# so you have room for title card and end card.
# Trim the extra in CapCut.

set -e
DURATION=3000

echo ""
echo "══════════════════════════════════════════════"
echo "  THE AMBER ROOM — 6 Ambient Layers"
echo "  Duration: $((DURATION/60)) minutes"
echo "  Each layer exported as a separate file"
echo "══════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════
# LAYER 1: WARM DRONE PAD
# CapCut volume: 22-25%
# A deep warm hum. Like the room itself is breathing.
# ═══════════════════════════════════════════
echo "[1/6] Warm Drone Pad..."
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$DURATION:c=brown:a=0.35" \
  -af "\
lowpass=f=200,\
highpass=f=20,\
tremolo=f=0.1:d=0.25,\
equalizer=f=60:t=h:width=40:g=6,\
equalizer=f=100:t=h:width=50:g=4,\
equalizer=f=150:t=h:width=40:g=2,\
volume=1.0,\
afade=t=in:ss=0:d=10,\
afade=t=out:ss=$((DURATION-25)):d=25" \
  _layer1_raw.wav 2>/dev/null

ffmpeg -y -i _layer1_raw.wav -af "loudnorm=I=-20:TP=-2:LRA=5" \
  LAYER1_warm_drone.wav 2>/dev/null
rm -f _layer1_raw.wav
echo "  ✓ LAYER1_warm_drone.wav — drag into CapCut at 22-25%"
echo ""

# ═══════════════════════════════════════════
# LAYER 2: RAIN ON WINDOW
# CapCut volume: 20-23%
# Steady gentle rain. The signature Amber Room sound.
# ═══════════════════════════════════════════
echo "[2/6] Rain on Window..."
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$DURATION:c=pink:a=0.40" \
  -af "\
lowpass=f=7000,\
highpass=f=250,\
tremolo=f=0.1:d=0.08,\
equalizer=f=600:t=h:width=300:g=-3,\
equalizer=f=2000:t=h:width=600:g=3,\
equalizer=f=4000:t=h:width=800:g=2,\
equalizer=f=5500:t=h:width=600:g=1,\
volume=1.0,\
afade=t=in:ss=0:d=12,\
afade=t=out:ss=$((DURATION-25)):d=25" \
  _layer2_raw.wav 2>/dev/null

ffmpeg -y -i _layer2_raw.wav -af "loudnorm=I=-20:TP=-2:LRA=5" \
  LAYER2_rain.wav 2>/dev/null
rm -f _layer2_raw.wav
echo "  ✓ LAYER2_rain.wav — drag into CapCut at 20-23%"
echo ""

# ═══════════════════════════════════════════
# LAYER 3: DISTANT THUNDER
# CapCut volume: 15-18%
# Deep far-away rumbles. Place ONLY in first 60% of timeline.
# ═══════════════════════════════════════════
echo "[3/6] Distant Thunder..."
THUNDER_DUR=$((DURATION * 65 / 100))
ffmpeg -y -f lavfi \
  -i "anoisesrc=d=$THUNDER_DUR:c=brown:a=0.45" \
  -af "\
lowpass=f=110,\
highpass=f=12,\
tremolo=f=0.1:d=0.94,\
equalizer=f=30:t=h:width=20:g=8,\
equalizer=f=60:t=h:width=30:g=5,\
equalizer=f=90:t=h:width=30:g=3,\
volume=1.0,\
afade=t=in:ss=0:d=8,\
afade=t=out:ss=$((THUNDER_DUR-60)):d=60" \
  _layer3_raw.wav 2>/dev/null

ffmpeg -y -i _layer3_raw.wav -af "loudnorm=I=-22:TP=-3:LRA=6" \
  LAYER3_thunder.wav 2>/dev/null
rm -f _layer3_raw.wav
echo "  ✓ LAYER3_thunder.wav — drag into CapCut at 15-18%"
echo "    IMPORTANT: Place this ONLY from 0:00 to $((THUNDER_DUR/60)) minutes"
echo "    Leave the rest of the timeline empty. Storm passes."
echo ""

# ═══════════════════════════════════════════
# LAYER 4: FIREPLACE CRACKLE
# CapCut volume: 12-15%
# Pops, crackles, ticks. Place ONLY in first 75% of timeline.
# ═══════════════════════════════════════════
echo "[4/6] Fireplace Crackle + Room Details..."
FIRE_DUR=$((DURATION * 78 / 100))

# Generate crackle sounds
ffmpeg -y -f lavfi -i "anoisesrc=d=0.07:c=white:a=0.25" \
  -af "highpass=f=2800,lowpass=f=10000,afade=t=out:ss=0.02:d=0.05,volume=0.5" \
  _pop.wav 2>/dev/null

ffmpeg -y -f lavfi -i "anoisesrc=d=0.14:c=white:a=0.18" \
  -af "highpass=f=2000,lowpass=f=8000,afade=t=in:ss=0:d=0.02,afade=t=out:ss=0.04:d=0.10,volume=0.4" \
  _crackle.wav 2>/dev/null

ffmpeg -y -f lavfi -i "sine=frequency=340:duration=0.30" \
  -af "tremolo=f=6:d=0.5,volume=0.2,afade=t=in:ss=0:d=0.05,afade=t=out:ss=0.10:d=0.20" \
  _creak.wav 2>/dev/null

ffmpeg -y -f lavfi -i "sine=frequency=3600:duration=0.04" \
  -af "afade=t=out:ss=0.01:d=0.03,volume=0.35" \
  _tick.wav 2>/dev/null

python3 << 'PYEOF'
import subprocess, random, os

DURATION = 3000
FIRE_DUR = DURATION * 78 // 100
full_dur = DURATION

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
while t < full_dur - 20:
    events.append((t, sounds[3]))
    t += random.randint(25, 50) if t < full_dur * 0.5 else random.randint(40, 70)

events.sort()
print(f"  Placing {len(events)} fire + detail events...")

subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i",
    f"anullsrc=r=48000:cl=stereo", "-t", str(full_dur),
    "_base.wav"], capture_output=True)

current = "_base.wav"
batch = 0
for i in range(0, len(events), 12):
    chunk = events[i:i+12]
    inputs = ["-i", current]
    filters = []
    mix = "[0]"
    for j, (sec, det) in enumerate(chunk):
        idx = j + 1
        inputs.extend(["-i", det])
        ms = int(sec * 1000)
        filters.append(f"[{idx}]adelay={ms}|{ms}[d{j}]")
        mix += f"[d{j}]"
    n = len(chunk) + 1
    filt = ";".join(filters) + f";{mix}amix=inputs={n}:duration=first:dropout_transition=0"
    out = f"_batch{batch}.wav"
    subprocess.run(["ffmpeg", "-y"] + inputs + ["-filter_complex", filt, "-t", str(full_dur), out], capture_output=True)
    if os.path.exists(out):
        current = out
    batch += 1
    if batch % 10 == 0:
        print(f"  Processed batch {batch}...")

# Normalize output
subprocess.run(["ffmpeg", "-y", "-i", current, "-af",
    f"volume=1.0,afade=t=in:ss=0:d=8,afade=t=out:ss={full_dur-45}:d=45,loudnorm=I=-20:TP=-2:LRA=6",
    "LAYER4_fireplace.wav"], capture_output=True)

# Cleanup
for f in os.listdir("."):
    if f.startswith("_batch") or f == "_base.wav":
        try: os.remove(f)
        except: pass

print(f"  ✓ {len(events)} events placed")
PYEOF

rm -f _pop.wav _crackle.wav _creak.wav _tick.wav
echo "  ✓ LAYER4_fireplace.wav — drag into CapCut at 12-15%"
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
volume=1.0,\
loudnorm=I=-25:TP=-3:LRA=4" \
  LAYER5_roomtone.wav 2>/dev/null
echo "  ✓ LAYER5_roomtone.wav — drag into CapCut at 10-12%"
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
  "[0]volume=0.15,afade=t=in:ss=0:d=30,afade=t=out:ss=$((DURATION-30)):d=30[left];\
   [1]volume=0.15,afade=t=in:ss=0:d=30,afade=t=out:ss=$((DURATION-30)):d=30[right];\
   [left][right]join=inputs=2:channel_layout=stereo,\
   loudnorm=I=-28:TP=-5:LRA=3" \
  LAYER6_binaural.wav 2>/dev/null
echo "  ✓ LAYER6_binaural.wav — drag into CapCut at 5-6%"
echo ""

# ═══════════════════════════════════════════
# DONE
# ═══════════════════════════════════════════
echo "══════════════════════════════════════════════"
echo ""
echo "  ✓ ALL 6 LAYERS GENERATED"
echo ""
echo "  Files:"
ls -lh LAYER*.wav | awk '{print "    " $NF " (" $5 ")"}'
echo ""
echo "  ══════════════════════════════════════"
echo "  CAPCUT CHEAT SHEET:"
echo "  ══════════════════════════════════════"
echo ""
echo "  Track 1: Your NotebookLM voiceover   → 100%"
echo "  Track 2: LAYER1_warm_drone.wav       → 22-25%"
echo "  Track 3: LAYER2_rain.wav             → 20-23%"
echo "  Track 4: LAYER3_thunder.wav          → 15-18%"
echo "           ⚠ FIRST 60% OF TIMELINE ONLY"
echo "  Track 5: LAYER4_fireplace.wav        → 12-15%"
echo "           (fire fades at 75%, ticks continue)"
echo "  Track 6: LAYER5_roomtone.wav         → 10-12%"
echo "  Track 7: LAYER6_binaural.wav         → 5-6%"
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
