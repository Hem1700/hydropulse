import wave
import struct
import math
import random
import os

SAMPLE_RATE = 44100
os.makedirs("assets/audio", exist_ok=True)

def write_wav(filename, samples, sample_rate=SAMPLE_RATE, num_channels=2):
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(num_channels)
        wav.setsampwidth(2) # 16-bit
        wav.setframerate(sample_rate)
        
        # Clamp and convert to 16-bit signed integers
        raw_data = bytearray()
        for frame in samples:
            if num_channels == 1:
                val = max(-32767, min(32767, int(frame * 32767.0)))
                raw_data.extend(struct.pack('<h', val))
            else:
                left, right = frame
                val_l = max(-32767, min(32767, int(left * 32767.0)))
                val_r = max(-32767, min(32767, int(right * 32767.0)))
                raw_data.extend(struct.pack('<hh', val_l, val_r))
        wav.writeframes(raw_data)
    print(f"Generated {filename}")

def generate_water_drop():
    duration = 0.45
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # Frequency rising sweep 750Hz -> 1800Hz
        freq = 750.0 + 1050.0 * (t / duration) ** 1.8
        phase = 2.0 * math.pi * freq * t
        # Fast attack, exponential decay
        envelope = (t / 0.015) if t < 0.015 else math.exp(-(t - 0.015) * 14.0)
        # Add slight resonant body
        body = math.sin(2.0 * math.pi * 320.0 * t) * math.exp(-t * 20.0) * 0.3
        val = (math.sin(phase) * 0.7 + body) * envelope * 0.8
        samples.append((val, val))
    
    write_wav("assets/audio/water_drop.wav", samples)

def generate_bowl_chime():
    duration = 3.5
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    # 528 Hz root + warm overtones
    harmonics = [
        (528.0, 0.5, 1.2),
        (1056.0, 0.25, 2.0),
        (1584.0, 0.15, 2.8),
        (2112.0, 0.08, 3.6),
        (264.0, 0.3, 0.9) # warm sub
    ]
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        val_l = 0.0
        val_r = 0.0
        for freq, amp, decay in harmonics:
            strike = (t / 0.008) if t < 0.008 else 1.0
            env = strike * math.exp(-t * decay)
            # slight stereo detuning for rich spatial acoustic shimmer
            val_l += math.sin(2.0 * math.pi * (freq - 0.5) * t) * amp * env
            val_r += math.sin(2.0 * math.pi * (freq + 0.5) * t) * amp * env
        
        samples.append((val_l * 0.7, val_r * 0.7))
        
    write_wav("assets/audio/bowl_chime.wav", samples)

def generate_brown_noise():
    # 8-second seamless loopable brown noise
    duration = 8.0
    total_samples = int(SAMPLE_RATE * duration)
    raw = [0.0] * total_samples
    
    # Brown noise integration
    last_out = 0.0
    for i in range(total_samples):
        white = random.uniform(-1.0, 1.0)
        last_out = (last_out + (0.02 * white)) / 1.02
        raw[i] = last_out * 3.5
    
    # Seamless loop crossfade (1.0s window)
    fade_len = int(SAMPLE_RATE * 1.0)
    for i in range(fade_len):
        w = i / fade_len
        idx_end = total_samples - fade_len + i
        blended = (1.0 - w) * raw[idx_end] + w * raw[i]
        raw[idx_end] = blended
        raw[i] = blended

    samples = []
    for val in raw:
        samples.append((val * 0.6, val * 0.6))
    write_wav("assets/audio/brown_noise.wav", samples)

def generate_rain():
    # 8-second seamless loopable rain
    duration = 8.0
    total_samples = int(SAMPLE_RATE * duration)
    raw_l = [0.0] * total_samples
    raw_r = [0.0] * total_samples
    
    # Filtered noise base
    b0_l, b1_l, b2_l = 0.0, 0.0, 0.0
    b0_r, b1_r, b2_r = 0.0, 0.0, 0.0
    
    for i in range(total_samples):
        w_l = random.uniform(-1.0, 1.0)
        w_r = random.uniform(-1.0, 1.0)
        
        # Pinkish-filtered rain background
        b0_l = 0.99 * b0_l + w_l * 0.05
        b1_l = 0.95 * b1_l + w_l * 0.05
        b2_l = 0.85 * b2_l + w_l * 0.05
        
        b0_r = 0.99 * b0_r + w_r * 0.05
        b1_r = 0.95 * b1_r + w_r * 0.05
        b2_r = 0.85 * b2_r + w_r * 0.05
        
        rain_l = (b0_l + b1_l + b2_l) * 0.4
        rain_r = (b0_r + b1_r + b2_r) * 0.4
        
        # Occasional soft raindrop patter
        if random.random() < 0.0015:
            drop = random.uniform(0.15, 0.35)
            rain_l += drop
        if random.random() < 0.0015:
            drop = random.uniform(0.15, 0.35)
            rain_r += drop
            
        raw_l[i] = rain_l
        raw_r[i] = rain_r

    # Crossfade loop ends
    fade_len = int(SAMPLE_RATE * 1.0)
    for i in range(fade_len):
        w = i / fade_len
        idx_end = total_samples - fade_len + i
        raw_l[idx_end] = (1.0 - w) * raw_l[idx_end] + w * raw_l[i]
        raw_l[i] = raw_l[idx_end]
        raw_r[idx_end] = (1.0 - w) * raw_r[idx_end] + w * raw_r[i]
        raw_r[i] = raw_r[idx_end]

    samples = [(l * 0.7, r * 0.7) for l, r in zip(raw_l, raw_r)]
    write_wav("assets/audio/rain.wav", samples)

def generate_stream():
    # 8-second soothing stream / brook loop
    duration = 8.0
    total_samples = int(SAMPLE_RATE * duration)
    raw_l = [0.0] * total_samples
    raw_r = [0.0] * total_samples
    
    lp_l = 0.0
    lp_r = 0.0
    bp_phase = 0.0
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        w_l = random.uniform(-1.0, 1.0)
        w_r = random.uniform(-1.0, 1.0)
        
        # Low pass smoothing
        lp_l = lp_l * 0.92 + w_l * 0.08
        lp_r = lp_r * 0.92 + w_r * 0.08
        
        # Resonant bubbling modulated over time
        bubble_mod_l = 0.5 + 0.5 * math.sin(2.0 * math.pi * 0.8 * t)
        bubble_mod_r = 0.5 + 0.5 * math.sin(2.0 * math.pi * 1.1 * t + 1.0)
        
        bubble_l = math.sin(2.0 * math.pi * (380.0 + 80.0 * bubble_mod_l) * t) * lp_l * 1.5
        bubble_r = math.sin(2.0 * math.pi * (420.0 + 70.0 * bubble_mod_r) * t) * lp_r * 1.5
        
        raw_l[i] = (lp_l * 1.8 + bubble_l) * 0.6
        raw_r[i] = (lp_r * 1.8 + bubble_r) * 0.6

    fade_len = int(SAMPLE_RATE * 1.0)
    for i in range(fade_len):
        w = i / fade_len
        idx_end = total_samples - fade_len + i
        raw_l[idx_end] = (1.0 - w) * raw_l[idx_end] + w * raw_l[i]
        raw_l[i] = raw_l[idx_end]
        raw_r[idx_end] = (1.0 - w) * raw_r[idx_end] + w * raw_r[i]
        raw_r[i] = raw_r[idx_end]

    samples = [(l * 0.65, r * 0.65) for l, r in zip(raw_l, raw_r)]
    write_wav("assets/audio/stream.wav", samples)

def generate_lofi_pulse():
    # 8-second warm ambient lofi drone loop
    duration = 8.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    # Warm chords: F minor / Ab major pad (174.6Hz F, 220Hz A, 261.6Hz C, 349.2Hz F)
    tones = [
        (174.61, 0.35),
        (220.00, 0.25),
        (261.63, 0.25),
        (349.23, 0.20),
        (87.31, 0.40) # deep sub
    ]
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # 60 BPM gentle breathing pulse (1.0 Hz)
        pulse = 0.85 + 0.15 * math.sin(2.0 * math.pi * 1.0 * t)
        val_l = 0.0
        val_r = 0.0
        
        for freq, amp in tones:
            # Subtle stereo chorus detune
            val_l += math.sin(2.0 * math.pi * (freq - 0.2) * t) * amp
            val_r += math.sin(2.0 * math.pi * (freq + 0.2) * t) * amp
            
        val_l = val_l * pulse * 0.35
        val_r = val_r * pulse * 0.35
        samples.append((val_l, val_r))

    write_wav("assets/audio/lofi_pulse.wav", samples)

if __name__ == "__main__":
    print("Generating audio soundscapes and sound effects...")
    generate_water_drop()
    generate_bowl_chime()
    generate_brown_noise()
    generate_rain()
    generate_stream()
    generate_lofi_pulse()
    print("All audio files generated successfully!")
