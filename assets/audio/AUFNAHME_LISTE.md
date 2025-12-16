# Audio-Aufnahme Checkliste

**Für:** Kids AI Apps (Alanko, Lianko)
**Format:** MP3, 44.1kHz, Mono oder Stereo
**Stimme:** Freundlich, kindgerecht, muttersprachlich

---

## BOSNISCH (bs) - PRIORITÄT 1

### correct (Lob bei richtiger Antwort)
- [ ] `correct_1.mp3` → **"Bravo!"**
- [ ] `correct_2.mp3` → **"Super!"**
- [ ] `correct_3.mp3` → **"Odlično!"** (Betonung: Ód-litsch-no)
- [ ] `correct_4.mp3` → **"Tako je!"**
- [ ] `correct_5.mp3` → **"Fantastično!"**

### wrong (Bei falscher Antwort - ermutigend!)
- [ ] `wrong_1.mp3` → **"Hajde probaj opet!"**
- [ ] `wrong_2.mp3` → **"Skoro!"**
- [ ] `wrong_3.mp3` → **"Ne brini, pokušaj ponovo!"**

### encourage (Ermutigung)
- [ ] `encourage_1.mp3` → **"Ti to možeš!"**
- [ ] `encourage_2.mp3` → **"Samo nastavi!"**
- [ ] `encourage_3.mp3` → **"Vjerujem u tebe!"**

### hello (Begrüßung)
- [ ] `hello_1.mp3` → **"Zdravo prijatelju!"**
- [ ] `hello_2.mp3` → **"Ćao!"** (Betonung: Tschao)
- [ ] `hello_3.mp3` → **"Hej, drago mi je što si tu!"**

### bye (Verabschiedung)
- [ ] `bye_1.mp3` → **"Doviđenja!"**
- [ ] `bye_2.mp3` → **"Vidimo se!"**
- [ ] `bye_3.mp3` → **"Bilo je super, ćao!"**

### thinking (Wenn KI "nachdenkt")
- [ ] `thinking_1.mp3` → **"Hmm, razmišljam..."**
- [ ] `thinking_2.mp3` → **"Daj da vidim..."**
- [ ] `thinking_3.mp3` → **"Zanimljivo..."**

**Bosnisch Total: 19 Dateien**

---

## DEUTSCH (de)

### correct
- [ ] `correct_1.mp3` → **"Super!"**
- [ ] `correct_2.mp3` → **"Toll!"**
- [ ] `correct_3.mp3` → **"Ausgezeichnet!"**
- [ ] `correct_4.mp3` → **"Richtig!"**
- [ ] `correct_5.mp3` → **"Fantastisch!"**

### wrong
- [ ] `wrong_1.mp3` → **"Versuch es nochmal!"**
- [ ] `wrong_2.mp3` → **"Fast!"**
- [ ] `wrong_3.mp3` → **"Keine Sorge, probier es nochmal!"**

### encourage
- [ ] `encourage_1.mp3` → **"Du schaffst das!"**
- [ ] `encourage_2.mp3` → **"Weiter so!"**
- [ ] `encourage_3.mp3` → **"Ich glaube an dich!"**

### hello
- [ ] `hello_1.mp3` → **"Hallo Freund!"**
- [ ] `hello_2.mp3` → **"Hi!"**
- [ ] `hello_3.mp3` → **"Hey, schön dass du da bist!"**

### bye
- [ ] `bye_1.mp3` → **"Tschüss!"**
- [ ] `bye_2.mp3` → **"Bis bald!"**
- [ ] `bye_3.mp3` → **"Das hat Spaß gemacht, tschüss!"**

### thinking
- [ ] `thinking_1.mp3` → **"Hmm, lass mich nachdenken..."**
- [ ] `thinking_2.mp3` → **"Mal sehen..."**
- [ ] `thinking_3.mp3` → **"Interessant..."**

**Deutsch Total: 19 Dateien**

---

## ENGLISCH (en)

### correct
- [ ] `correct_1.mp3` → **"Great job!"**
- [ ] `correct_2.mp3` → **"Awesome!"**
- [ ] `correct_3.mp3` → **"You got it!"**
- [ ] `correct_4.mp3` → **"Perfect!"**
- [ ] `correct_5.mp3` → **"Amazing!"**

### wrong
- [ ] `wrong_1.mp3` → **"Try again!"**
- [ ] `wrong_2.mp3` → **"Almost!"**
- [ ] `wrong_3.mp3` → **"Don't worry, try once more!"**

### encourage
- [ ] `encourage_1.mp3` → **"You can do it!"**
- [ ] `encourage_2.mp3` → **"Keep going!"**
- [ ] `encourage_3.mp3` → **"I believe in you!"**

### hello
- [ ] `hello_1.mp3` → **"Hello friend!"**
- [ ] `hello_2.mp3` → **"Hi there!"**
- [ ] `hello_3.mp3` → **"Hey, I'm glad you're here!"**

### bye
- [ ] `bye_1.mp3` → **"Goodbye!"**
- [ ] `bye_2.mp3` → **"See you soon!"**
- [ ] `bye_3.mp3` → **"That was fun, bye!"**

### thinking
- [ ] `thinking_1.mp3` → **"Hmm, let me think..."**
- [ ] `thinking_2.mp3` → **"Let me see..."**
- [ ] `thinking_3.mp3` → **"Interesting..."**

**Englisch Total: 19 Dateien**

---

## Aufnahme-Tipps

1. **Stimmung:** Fröhlich, warm, kindgerecht
2. **Tempo:** Nicht zu schnell (Kinder 3-12 Jahre)
3. **Lautstärke:** Konsistent über alle Dateien
4. **Hintergrund:** Kein Rauschen, keine Echos
5. **Dateiname:** Exakt wie oben angegeben!

---

## Ordnerstruktur

```
assets/audio/
├── bs/
│   ├── correct_1.mp3
│   ├── correct_2.mp3
│   └── ...
├── de/
│   └── ...
├── en/
│   └── ...
├── hr/
│   └── ...
├── sr/
│   └── ...
└── tr/
    └── ...
```

---

## Nach Aufnahme

Audio-Dateien in den entsprechenden Ordner legen, dann:
```bash
flutter pub get
```

Die App erkennt automatisch welche Dateien vorhanden sind.
