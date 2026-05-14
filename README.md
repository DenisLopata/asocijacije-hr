# Asocijacije 🟨🟩🟦🟪

> A Croatian word association game where your vocabulary goes to suffer.

**Play it live:** https://asocijacije-hr.web.app

---

## What is this?

You get 16 words. They secretly belong to 4 categories. Your job is to figure out which four go together before you run out of guesses.

Sounds easy. It isn't. That's the point.

Built with Godot 4, deployed on Firebase, and powered by the collective anxiety of Croatian vocabulary tests.

## How to play

1. Look at 16 words
2. Think you know what they have in common
3. Select 4 words
4. Click Potvrdi
5. Be wrong
6. Repeat until enlightened or out of guesses

## Features

- 5 handcrafted puzzles per session
- 4 colour-coded difficulty levels (yellow = easy, purple = "why am I like this")
- Hint system for when you've given up but haven't admitted it yet
- Subtle shimmer animation on correct answers so you feel smart
- Saves your progress so you can feel bad about it later too

## Tech stack

- **Engine:** Godot 4.6
- **Hosting:** Firebase Hosting
- **CI/CD:** GitHub Actions (Godot headless export → Firebase deploy)
- **Font:** Outfit (text) + Material Symbols (icons)
- **Language:** GDScript, regret

## Development

```bash
# Clone the repo
git clone https://github.com/DenisLopata/asocijacije-hr.git

# Open in Godot 4.6
# Project → Export → Web → Export Project → export/web/index.html

# Deploy manually
firebase deploy --only hosting
```

Pushing to `main` triggers automatic export and deploy via GitHub Actions.

## Adding puzzles

Open `scripts/puzzle_data.gd` and add an entry to the `_PUZZLES` array. Each puzzle needs 4 categories with 4 words each and a difficulty rank (0–3). Try to make at least one category deceptively obvious. That's where the fun is.

---

*Made in Croatia. Tested on people who think they're good at Croatian. They weren't.*
