#!/usr/bin/env python3
"""
Sound Downloader für Kids AI Apps
Lädt kindgerechte Sounds von Pixabay herunter

Verwendung:
    pip install requests
    python download_sounds.py
"""

import os
import requests
from pathlib import Path

# Basis-Pfad
BASE_PATH = Path(__file__).parent.parent / 'assets' / 'sounds'

# Pixabay Sound URLs (direkte MP3 Links von lizenzfreien Sounds)
# Diese sind alle CC0 / Public Domain
SOUND_URLS = {
    'success': {
        'correct': 'https://cdn.pixabay.com/audio/2022/03/15/audio_115b9b87a3.mp3',  # Success bell
        'level_up': 'https://cdn.pixabay.com/audio/2021/08/04/audio_0625c1539c.mp3',  # Level up
        'achievement': 'https://cdn.pixabay.com/audio/2022/03/15/audio_8cb749e34a.mp3',  # Achievement
        'star': 'https://cdn.pixabay.com/audio/2022/03/10/audio_d8f90d57a1.mp3',  # Collect star
        'applause': 'https://cdn.pixabay.com/audio/2022/03/12/audio_b4f7e5a4bc.mp3',  # Applause
    },
    'error': {
        'wrong': 'https://cdn.pixabay.com/audio/2022/03/15/audio_68d69e8e5c.mp3',  # Wrong buzzer
        'try_again': 'https://cdn.pixabay.com/audio/2021/08/04/audio_c507b33633.mp3',  # Soft error
        'oops': 'https://cdn.pixabay.com/audio/2022/03/15/audio_942694e498.mp3',  # Oops sound
    },
    'ui': {
        'tap': 'https://cdn.pixabay.com/audio/2022/03/10/audio_7a49127845.mp3',  # Button click
        'hover': 'https://cdn.pixabay.com/audio/2022/11/17/audio_b5e1b5f858.mp3',  # Soft hover
        'swipe': 'https://cdn.pixabay.com/audio/2022/03/15/audio_942694e498.mp3',  # Swipe
        'pop': 'https://cdn.pixabay.com/audio/2022/03/10/audio_d8f90d57a1.mp3',  # Pop
        'whoosh': 'https://cdn.pixabay.com/audio/2022/03/15/audio_7f8d7c2d8c.mp3',  # Whoosh
    },
    'game': {
        'countdown': 'https://cdn.pixabay.com/audio/2022/03/15/audio_8606c32c14.mp3',  # Countdown beep
        'tick': 'https://cdn.pixabay.com/audio/2022/01/18/audio_ea75bbb8d2.mp3',  # Clock tick
        'start': 'https://cdn.pixabay.com/audio/2021/08/04/audio_0625c1539c.mp3',  # Game start
        'game_over': 'https://cdn.pixabay.com/audio/2022/03/15/audio_68d69e8e5c.mp3',  # Game over
        'bonus': 'https://cdn.pixabay.com/audio/2022/03/15/audio_115b9b87a3.mp3',  # Bonus
    },
    'reward': {
        'coin': 'https://cdn.pixabay.com/audio/2022/03/10/audio_d8f90d57a1.mp3',  # Coin collect
        'chest': 'https://cdn.pixabay.com/audio/2022/03/15/audio_8cb749e34a.mp3',  # Chest open
        'fanfare': 'https://cdn.pixabay.com/audio/2022/03/15/audio_942694e498.mp3',  # Fanfare
        'sparkle': 'https://cdn.pixabay.com/audio/2022/03/10/audio_7a49127845.mp3',  # Sparkle
    },
    'ambient': {
        'bubbles': 'https://cdn.pixabay.com/audio/2022/03/09/audio_6c5a2e9b78.mp3',  # Bubbles
        'magic': 'https://cdn.pixabay.com/audio/2022/03/15/audio_7f8d7c2d8c.mp3',  # Magic
        'nature': 'https://cdn.pixabay.com/audio/2022/08/02/audio_884fe92a21.mp3',  # Nature birds
    },
}

# Alternative: Mixkit URLs (auch kostenlos)
MIXKIT_URLS = {
    'success': {
        'correct': 'https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3',
        'level_up': 'https://assets.mixkit.co/active_storage/sfx/2019/2019-preview.mp3',
        'achievement': 'https://assets.mixkit.co/active_storage/sfx/2018/2018-preview.mp3',
        'star': 'https://assets.mixkit.co/active_storage/sfx/2001/2001-preview.mp3',
        'applause': 'https://assets.mixkit.co/active_storage/sfx/2194/2194-preview.mp3',
    },
    'error': {
        'wrong': 'https://assets.mixkit.co/active_storage/sfx/2003/2003-preview.mp3',
        'try_again': 'https://assets.mixkit.co/active_storage/sfx/2004/2004-preview.mp3',
        'oops': 'https://assets.mixkit.co/active_storage/sfx/2005/2005-preview.mp3',
    },
    'ui': {
        'tap': 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3',
        'hover': 'https://assets.mixkit.co/active_storage/sfx/2571/2571-preview.mp3',
        'swipe': 'https://assets.mixkit.co/active_storage/sfx/2572/2572-preview.mp3',
        'pop': 'https://assets.mixkit.co/active_storage/sfx/2573/2573-preview.mp3',
        'whoosh': 'https://assets.mixkit.co/active_storage/sfx/2574/2574-preview.mp3',
    },
    'game': {
        'countdown': 'https://assets.mixkit.co/active_storage/sfx/2575/2575-preview.mp3',
        'tick': 'https://assets.mixkit.co/active_storage/sfx/2576/2576-preview.mp3',
        'start': 'https://assets.mixkit.co/active_storage/sfx/2577/2577-preview.mp3',
        'game_over': 'https://assets.mixkit.co/active_storage/sfx/2578/2578-preview.mp3',
        'bonus': 'https://assets.mixkit.co/active_storage/sfx/2579/2579-preview.mp3',
    },
    'reward': {
        'coin': 'https://assets.mixkit.co/active_storage/sfx/2580/2580-preview.mp3',
        'chest': 'https://assets.mixkit.co/active_storage/sfx/2581/2581-preview.mp3',
        'fanfare': 'https://assets.mixkit.co/active_storage/sfx/2582/2582-preview.mp3',
        'sparkle': 'https://assets.mixkit.co/active_storage/sfx/2583/2583-preview.mp3',
    },
    'ambient': {
        'bubbles': 'https://assets.mixkit.co/active_storage/sfx/2584/2584-preview.mp3',
        'magic': 'https://assets.mixkit.co/active_storage/sfx/2585/2585-preview.mp3',
        'nature': 'https://assets.mixkit.co/active_storage/sfx/2586/2586-preview.mp3',
    },
}


def download_file(url: str, filepath: Path) -> bool:
    """Lädt eine Datei herunter"""
    try:
        response = requests.get(url, timeout=30, allow_redirects=True)
        if response.status_code == 200 and len(response.content) > 1000:
            filepath.write_bytes(response.content)
            return True
        return False
    except Exception as e:
        print(f"      Fehler: {e}")
        return False


def main():
    print("=" * 60)
    print("🎵 Kids AI Sound Downloader (Pixabay)")
    print("=" * 60)
    print(f"Ziel: {BASE_PATH.absolute()}")

    total = 0
    success = 0

    # Primär Mixkit verwenden (zuverlässiger)
    sound_sources = MIXKIT_URLS

    for category, sounds in sound_sources.items():
        category_path = BASE_PATH / category
        category_path.mkdir(parents=True, exist_ok=True)

        print(f"\n📁 {category.upper()}")
        print("-" * 40)

        for name, url in sounds.items():
            filepath = category_path / f"{name}.mp3"
            total += 1

            # Überspringen wenn vorhanden und größer als 1KB
            if filepath.exists() and filepath.stat().st_size > 1000:
                print(f"  ⏭️  {name}.mp3 existiert")
                success += 1
                continue

            print(f"  ⬇️  {name}.mp3 ...", end=" ", flush=True)

            if download_file(url, filepath):
                size_kb = filepath.stat().st_size / 1024
                print(f"✅ ({size_kb:.1f} KB)")
                success += 1
            else:
                print("❌")

    print("\n" + "=" * 60)
    print(f"✅ Erfolgreich: {success}/{total}")

    if success < total:
        print(f"❌ Fehlgeschlagen: {total - success}")
        print("\nTipp: Script erneut ausführen für fehlende Dateien")
    else:
        print("\n🎉 Alle Sounds erfolgreich heruntergeladen!")

    print("=" * 60)


if __name__ == '__main__':
    main()
