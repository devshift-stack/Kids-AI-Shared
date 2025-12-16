#!/usr/bin/env python3
"""
Audio Generator für Kids AI Apps
Generiert alle Pre-recorded Phrasen mit Edge TTS (Vesna-Stimme)

Verwendung:
    pip install edge-tts
    python generate_audio.py

Ausgabe:
    assets/audio/{sprache}/{typ}_{nummer}.mp3
"""

import asyncio
import os
import edge_tts

# Basis-Pfad für Audio-Dateien
BASE_PATH = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')

# Stimmen pro Sprache
VOICES = {
    'bs': 'bs-BA-VesnaNeural',      # Bosnisch - Vesna
    'de': 'de-DE-KatjaNeural',      # Deutsch - Katja
    'en': 'en-US-JennyNeural',      # Englisch - Jenny
    'hr': 'hr-HR-GabrijelaNeural',  # Kroatisch - Gabrijela
    'sr': 'sr-RS-SophieNeural',     # Serbisch - Sophie
    'tr': 'tr-TR-EmelNeural',       # Türkisch - Emel
}

# Phrasen pro Sprache und Typ
PHRASES = {
    'bs': {
        'correct': ['Bravo!', 'Super!', 'Odlično!', 'Tako je!', 'Fantastično!'],
        'wrong': ['Hajde probaj opet!', 'Skoro!', 'Ne brini, pokušaj ponovo!'],
        'encourage': ['Ti to možeš!', 'Samo nastavi!', 'Vjerujem u tebe!'],
        'hello': ['Zdravo prijatelju!', 'Ćao!', 'Hej, drago mi je što si tu!'],
        'bye': ['Doviđenja!', 'Vidimo se!', 'Bilo je super, ćao!'],
        'thinking': ['Hmm, razmišljam...', 'Daj da vidim...', 'Zanimljivo...'],
    },
    'de': {
        'correct': ['Super!', 'Toll!', 'Ausgezeichnet!', 'Richtig!', 'Fantastisch!'],
        'wrong': ['Versuch es nochmal!', 'Fast!', 'Keine Sorge, probier es nochmal!'],
        'encourage': ['Du schaffst das!', 'Weiter so!', 'Ich glaube an dich!'],
        'hello': ['Hallo Freund!', 'Hi!', 'Hey, schön dass du da bist!'],
        'bye': ['Tschüss!', 'Bis bald!', 'Das hat Spaß gemacht, tschüss!'],
        'thinking': ['Hmm, lass mich nachdenken...', 'Mal sehen...', 'Interessant...'],
    },
    'en': {
        'correct': ['Great job!', 'Awesome!', 'You got it!', 'Perfect!', 'Amazing!'],
        'wrong': ['Try again!', 'Almost!', "Don't worry, try once more!"],
        'encourage': ['You can do it!', 'Keep going!', 'I believe in you!'],
        'hello': ['Hello friend!', 'Hi there!', "Hey, I'm glad you're here!"],
        'bye': ['Goodbye!', 'See you soon!', 'That was fun, bye!'],
        'thinking': ['Hmm, let me think...', 'Let me see...', 'Interesting...'],
    },
    'hr': {
        'correct': ['Bravo!', 'Super!', 'Odlično!', 'Tako je!', 'Fantastično!'],
        'wrong': ['Pokušaj opet!', 'Skoro!', 'Ne brini, probaj ponovno!'],
        'encourage': ['Možeš ti to!', 'Samo nastavi!', 'Vjerujem u tebe!'],
        'hello': ['Bok prijatelju!', 'Ćao!', 'Hej, drago mi je što si tu!'],
        'bye': ['Doviđenja!', 'Vidimo se!', 'Bilo je super, bok!'],
        'thinking': ['Hmm, razmišljam...', 'Da vidim...', 'Zanimljivo...'],
    },
    'sr': {
        'correct': ['Браво!', 'Супер!', 'Одлично!', 'Тако је!', 'Фантастично!'],
        'wrong': ['Пробај поново!', 'Скоро!', 'Не брини, покушај опет!'],
        'encourage': ['Можеш ти то!', 'Само настави!', 'Верујем у тебе!'],
        'hello': ['Здраво пријатељу!', 'Ћао!', 'Хеј, драго ми је што си ту!'],
        'bye': ['Довиђења!', 'Видимо се!', 'Било је супер, ћао!'],
        'thinking': ['Хмм, размишљам...', 'Да видим...', 'Занимљиво...'],
    },
    'tr': {
        'correct': ['Aferin!', 'Süper!', 'Mükemmel!', 'Doğru!', 'Harika!'],
        'wrong': ['Tekrar dene!', 'Neredeyse!', 'Endişelenme, bir daha dene!'],
        'encourage': ['Yapabilirsin!', 'Devam et!', 'Sana inanıyorum!'],
        'hello': ['Merhaba arkadaşım!', 'Selam!', 'Hey, burada olduğuna sevindim!'],
        'bye': ['Hoşça kal!', 'Görüşürüz!', 'Çok eğlenceliydi, bay bay!'],
        'thinking': ['Hmm, düşüneyim...', 'Bakalım...', 'İlginç...'],
    },
}

# TTS Einstellungen
RATE = '-10%'   # Etwas langsamer für Kinder
PITCH = '+5%'   # Etwas höher = freundlicher


async def generate_audio(text: str, voice: str, output_path: str) -> bool:
    """Generiert eine einzelne Audio-Datei"""
    try:
        communicate = edge_tts.Communicate(
            text,
            voice,
            rate=RATE,
            pitch=PITCH
        )
        await communicate.save(output_path)
        return True
    except Exception as e:
        print(f"  ❌ Fehler: {e}")
        return False


async def generate_language(lang: str) -> tuple[int, int]:
    """Generiert alle Audio-Dateien für eine Sprache"""
    voice = VOICES.get(lang)
    phrases = PHRASES.get(lang)

    if not voice or not phrases:
        print(f"⚠️  Sprache '{lang}' nicht konfiguriert")
        return 0, 0

    lang_path = os.path.join(BASE_PATH, lang)
    os.makedirs(lang_path, exist_ok=True)

    success = 0
    failed = 0

    print(f"\n🔊 Generiere {lang.upper()} mit Stimme: {voice}")
    print("-" * 50)

    for phrase_type, texts in phrases.items():
        for i, text in enumerate(texts, 1):
            filename = f"{phrase_type}_{i}.mp3"
            filepath = os.path.join(lang_path, filename)

            # Überspringen wenn bereits vorhanden
            if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
                print(f"  ⏭️  {filename} existiert bereits")
                success += 1
                continue

            print(f"  🎙️  {filename}: \"{text}\"")

            if await generate_audio(text, voice, filepath):
                success += 1
                print(f"      ✅ Gespeichert")
            else:
                failed += 1

    return success, failed


async def main():
    """Hauptfunktion"""
    print("=" * 60)
    print("🎵 Kids AI Audio Generator")
    print("=" * 60)
    print(f"Ausgabe-Pfad: {os.path.abspath(BASE_PATH)}")

    total_success = 0
    total_failed = 0

    # Nur die wichtigsten Sprachen zuerst
    priority_langs = ['bs', 'de', 'en']
    other_langs = ['hr', 'sr', 'tr']

    print("\n📌 Priorität 1: Bosnisch, Deutsch, Englisch")
    for lang in priority_langs:
        success, failed = await generate_language(lang)
        total_success += success
        total_failed += failed

    print("\n📌 Priorität 2: Kroatisch, Serbisch, Türkisch")
    for lang in other_langs:
        success, failed = await generate_language(lang)
        total_success += success
        total_failed += failed

    print("\n" + "=" * 60)
    print(f"✅ Erfolgreich: {total_success}")
    print(f"❌ Fehlgeschlagen: {total_failed}")
    print("=" * 60)

    if total_failed == 0:
        print("\n🎉 Alle Audio-Dateien wurden erfolgreich generiert!")
        print(f"   Pfad: {os.path.abspath(BASE_PATH)}")
    else:
        print("\n⚠️  Einige Dateien konnten nicht generiert werden.")
        print("   Bitte Script erneut ausführen.")


if __name__ == '__main__':
    asyncio.run(main())
