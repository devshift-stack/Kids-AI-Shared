#!/usr/bin/env python3
"""
Sound Effects Generator für Kids AI Apps
Generiert einfache Sound-Effekte mit pydub/numpy

Verwendung:
    pip install pydub numpy
    python generate_sounds.py

Ausgabe:
    assets/sounds/{kategorie}/{sound}.mp3
"""

import os
import numpy as np
from pathlib import Path

try:
    from pydub import AudioSegment
    from pydub.generators import Sine, Square, Sawtooth
    PYDUB_AVAILABLE = True
except ImportError:
    PYDUB_AVAILABLE = False
    print("⚠️  pydub nicht installiert. Installiere mit: pip install pydub")

# Basis-Pfad
BASE_PATH = Path(__file__).parent.parent / 'assets' / 'sounds'

# Sound-Definitionen
SOUNDS = {
    'success': {
        'correct': {'freq': 880, 'duration': 200, 'type': 'rising'},
        'level_up': {'freq': 440, 'duration': 500, 'type': 'fanfare'},
        'achievement': {'freq': 660, 'duration': 400, 'type': 'fanfare'},
        'star': {'freq': 1200, 'duration': 150, 'type': 'sparkle'},
        'applause': {'freq': 500, 'duration': 1000, 'type': 'noise'},
    },
    'error': {
        'wrong': {'freq': 200, 'duration': 300, 'type': 'falling'},
        'try_again': {'freq': 300, 'duration': 250, 'type': 'wobble'},
        'oops': {'freq': 250, 'duration': 200, 'type': 'falling'},
    },
    'ui': {
        'tap': {'freq': 600, 'duration': 50, 'type': 'click'},
        'hover': {'freq': 800, 'duration': 30, 'type': 'click'},
        'swipe': {'freq': 400, 'duration': 150, 'type': 'sweep'},
        'pop': {'freq': 1000, 'duration': 80, 'type': 'pop'},
        'whoosh': {'freq': 300, 'duration': 200, 'type': 'sweep'},
    },
    'game': {
        'countdown': {'freq': 440, 'duration': 300, 'type': 'beep'},
        'tick': {'freq': 800, 'duration': 50, 'type': 'click'},
        'start': {'freq': 523, 'duration': 400, 'type': 'fanfare'},
        'game_over': {'freq': 200, 'duration': 600, 'type': 'falling'},
        'bonus': {'freq': 880, 'duration': 300, 'type': 'rising'},
    },
    'reward': {
        'coin': {'freq': 1400, 'duration': 100, 'type': 'sparkle'},
        'chest': {'freq': 300, 'duration': 500, 'type': 'magic'},
        'fanfare': {'freq': 440, 'duration': 800, 'type': 'fanfare'},
        'sparkle': {'freq': 1600, 'duration': 200, 'type': 'sparkle'},
    },
    'ambient': {
        'bubbles': {'freq': 600, 'duration': 2000, 'type': 'bubbles'},
        'magic': {'freq': 800, 'duration': 1000, 'type': 'magic'},
        'nature': {'freq': 400, 'duration': 3000, 'type': 'noise'},
    },
}


def generate_tone(freq: int, duration: int, sound_type: str) -> AudioSegment:
    """Generiert einen Ton basierend auf Typ"""

    if sound_type == 'click':
        # Kurzer Klick
        tone = Sine(freq).to_audio_segment(duration=duration)
        tone = tone.fade_in(5).fade_out(duration // 2)

    elif sound_type == 'rising':
        # Aufsteigend
        tone = AudioSegment.silent(duration=0)
        steps = 5
        step_duration = duration // steps
        for i in range(steps):
            step_freq = freq + (i * 100)
            step_tone = Sine(step_freq).to_audio_segment(duration=step_duration)
            tone += step_tone
        tone = tone.fade_in(20).fade_out(50)

    elif sound_type == 'falling':
        # Absteigend
        tone = AudioSegment.silent(duration=0)
        steps = 4
        step_duration = duration // steps
        for i in range(steps):
            step_freq = freq - (i * 50)
            step_tone = Sine(max(100, step_freq)).to_audio_segment(duration=step_duration)
            tone += step_tone
        tone = tone.fade_out(100)

    elif sound_type == 'fanfare':
        # Fanfare (mehrere Töne)
        notes = [freq, freq * 1.25, freq * 1.5, freq * 2]
        tone = AudioSegment.silent(duration=0)
        note_duration = duration // len(notes)
        for note in notes:
            note_tone = Sine(note).to_audio_segment(duration=note_duration)
            note_tone = note_tone.fade_in(10).fade_out(30)
            tone += note_tone

    elif sound_type == 'sparkle':
        # Glitzer-Sound
        tone = Sine(freq).to_audio_segment(duration=duration // 3)
        tone += Sine(freq * 1.5).to_audio_segment(duration=duration // 3)
        tone += Sine(freq * 2).to_audio_segment(duration=duration // 3)
        tone = tone.fade_in(10).fade_out(50)

    elif sound_type == 'wobble':
        # Wackel-Sound
        tone = AudioSegment.silent(duration=0)
        wobbles = 4
        wobble_duration = duration // wobbles
        for i in range(wobbles):
            wobble_freq = freq + ((-1) ** i * 50)
            wobble_tone = Sine(wobble_freq).to_audio_segment(duration=wobble_duration)
            tone += wobble_tone
        tone = tone.fade_out(50)

    elif sound_type == 'sweep':
        # Sweep-Sound
        tone = AudioSegment.silent(duration=0)
        steps = 10
        step_duration = duration // steps
        for i in range(steps):
            step_freq = freq + (i * 50)
            step_tone = Sine(step_freq).to_audio_segment(duration=step_duration)
            step_tone = step_tone - (i * 2)  # Volume decrease
            tone += step_tone
        tone = tone.fade_in(20).fade_out(50)

    elif sound_type == 'pop':
        # Pop-Sound
        tone = Sine(freq).to_audio_segment(duration=duration // 2)
        tone += Sine(freq * 0.5).to_audio_segment(duration=duration // 2)
        tone = tone.fade_in(5).fade_out(30)

    elif sound_type == 'beep':
        # Beep
        tone = Sine(freq).to_audio_segment(duration=duration)
        tone = tone.fade_in(10).fade_out(50)

    elif sound_type == 'magic':
        # Magischer Sound
        tone = AudioSegment.silent(duration=0)
        for i in range(5):
            magic_freq = freq + (i * 200)
            magic_tone = Sine(magic_freq).to_audio_segment(duration=duration // 5)
            magic_tone = magic_tone - (i * 3)
            tone += magic_tone
        tone = tone.fade_in(50).fade_out(200)

    elif sound_type == 'bubbles':
        # Blubbern
        tone = AudioSegment.silent(duration=0)
        bubble_count = duration // 100
        for _ in range(bubble_count):
            bubble_freq = freq + np.random.randint(-200, 200)
            bubble_duration = np.random.randint(50, 150)
            bubble = Sine(bubble_freq).to_audio_segment(duration=bubble_duration)
            bubble = bubble.fade_in(10).fade_out(30) - 10
            silence = AudioSegment.silent(duration=np.random.randint(20, 80))
            tone += bubble + silence

    elif sound_type == 'noise':
        # Ambient noise (weißes Rauschen simuliert)
        tone = AudioSegment.silent(duration=0)
        for _ in range(duration // 50):
            noise_freq = freq + np.random.randint(-100, 100)
            noise = Sine(noise_freq).to_audio_segment(duration=50) - 20
            tone += noise
        tone = tone.fade_in(200).fade_out(500)

    else:
        # Standard Sinus
        tone = Sine(freq).to_audio_segment(duration=duration)
        tone = tone.fade_in(20).fade_out(50)

    return tone


def generate_all_sounds():
    """Generiert alle Sound-Effekte"""

    if not PYDUB_AVAILABLE:
        print("❌ pydub nicht verfügbar. Bitte installieren:")
        print("   pip install pydub")
        return

    print("=" * 60)
    print("🎵 Kids AI Sound Effects Generator")
    print("=" * 60)

    total = 0
    generated = 0

    for category, sounds in SOUNDS.items():
        category_path = BASE_PATH / category
        category_path.mkdir(parents=True, exist_ok=True)

        print(f"\n📁 {category.upper()}")
        print("-" * 40)

        for name, config in sounds.items():
            filepath = category_path / f"{name}.mp3"
            total += 1

            # Überspringen wenn vorhanden
            if filepath.exists() and filepath.stat().st_size > 0:
                print(f"  ⏭️  {name}.mp3 existiert bereits")
                generated += 1
                continue

            try:
                tone = generate_tone(
                    config['freq'],
                    config['duration'],
                    config['type']
                )

                # Normalisieren und exportieren
                tone = tone.normalize()
                tone.export(filepath, format='mp3')

                print(f"  ✅ {name}.mp3 generiert")
                generated += 1

            except Exception as e:
                print(f"  ❌ {name}.mp3 Fehler: {e}")

    print("\n" + "=" * 60)
    print(f"✅ Generiert: {generated}/{total}")
    print(f"📁 Pfad: {BASE_PATH.absolute()}")
    print("=" * 60)


if __name__ == '__main__':
    generate_all_sounds()
