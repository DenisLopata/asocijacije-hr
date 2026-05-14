# Beskraj — Roguelike Mode Design

## Concept

An endless, escalating run through word-association puzzles. The player starts with a small life pool and pushes as deep as possible. Each wrong guess costs a life; each solved puzzle earns rewards and increases difficulty. The run ends when lives reach zero. Score is based on depth and performance.

Replaces Nova igra on the main menu. No daily restriction — playable any time, any number of times.

---

## Core loop

```
Start run (3 lives, depth 1)
  └─ Load puzzle (difficulty scaled to depth)
       ├─ Solve without mistakes → reward + depth++
       ├─ Solve with mistakes    → depth++ (no reward)
       └─ Lose all lives mid-puzzle → Run over
```

---

## Lives

- Start with **3 lives**.
- Each wrong guess costs **1 life** (same as normal mode — 4 mistakes = game over on a single puzzle).
- Lives carry over between puzzles — a mistake on puzzle 3 still hurts on puzzle 5.
- **Maximum lives: 5.** Cannot exceed this.

### Life rewards (on clean solve — zero mistakes)
| Depth reached | Reward |
|--------------|--------|
| Every 5th puzzle | +1 life |
| Solve a PURPLE category | +1 life (once per puzzle) |

---

## Difficulty ramp

Puzzles are drawn from `PuzzleData` using a weighted category difficulty profile that shifts as depth increases.

| Depth | YELLOW | GREEN | BLUE | PURPLE |
|-------|--------|-------|------|--------|
| 1–3   | 50%    | 35%   | 15%  | 0%     |
| 4–6   | 35%    | 35%   | 25%  | 5%     |
| 7–10  | 20%    | 30%   | 35%  | 15%    |
| 11–15 | 10%    | 25%   | 40%  | 25%    |
| 16+   | 5%     | 20%   | 40%  | 35%    |

Within each tier, `rank` is also weighted — higher ranks (harder within tier) become more common at greater depth.

Seed for each puzzle: `run_seed + depth` — deterministic per run, different every run (run_seed is random at start).

---

## Scoring

**Base score per puzzle:** same formula as existing modes (based on mistakes, hints, speed).

**Depth multiplier:** `1.0 + (depth - 1) * 0.15` — caps at `4.0` (depth 21+).

**Run score:** sum of `puzzle_score × depth_multiplier` across all solved puzzles.

The multiplier makes deep runs disproportionately valuable — a clean late puzzle is worth much more than an early one.

---

## Hints

- Start with **2 hints** per run (not per puzzle).
- Hints do **not** restore between puzzles.
- No way to earn more hints mid-run.
- This makes hints a strategic resource — save them for deep puzzles.

---

## Run-over screen

Shows on death (lives = 0):

- **Depth reached** (puzzles solved)
- **Total score**
- **Best depth / best score** (all-time personal bests from prefs)
- New best highlighted if beaten
- Two buttons: **Ponovno** (play again) / **Izbornik** (menu)

No name picker, no leaderboard submission — this is a single-player score-chase mode.

---

## Persistence

Stored in `prefs.cfg` under section `beskraj`:
- `best_depth: int` — all-time deepest run
- `best_score: int` — all-time highest score

No in-progress save — if the app closes mid-run, the run is lost. (Acceptable: runs are short enough.)

---

## UI changes

### Main menu
Replace the **Nova igra** button with **Beskraj**. Style: reuse `C_BTN_PRIMARY` (blue) with a subtitle showing personal best if one exists:
- No best yet: `"Koliko duboko možeš?"` (How deep can you go?)
- Best exists: `"Rekord: dubina %d  •  %d bod"` (Record: depth N • N points)

### In-game HUD changes (game_screen.gd)
Beskraj run needs a few extra HUD elements alongside the existing puzzle UI:

- **Life display** — row of heart icons (filled/empty) replacing or sitting beside the existing mistake dots. Use Material Symbols `favorite` (0xE87D) and `favorite_border` (0xE87E).
- **Depth counter** — replaces puzzle counter prefix. Shows `"Dubina %d"` instead of `"Slagalica %d/%d"`.
- **Run score** — running total, updates as puzzles complete (same as existing score label).
- **Multiplier badge** — small label showing current multiplier `"×1.45"`, updates per depth. Subtle, MetaLabel style.

### Puzzle counter prefix
Add `"Beskraj  "` as the prefix string for this mode (alongside existing `"Dnevni  "`, `"Dnevnih 5  "`, `"Slagalica "`).

---

## State machine additions

`GameState` (or a thin wrapper) needs:
- `run_lives: int`
- `run_depth: int`
- `run_score: float`
- `run_seed: int`
- `is_beskraj: bool`

On puzzle completion in `game_screen.gd`:
1. Apply depth multiplier to puzzle score, add to `run_score`
2. Check life reward conditions, update `run_lives`
3. Increment `run_depth`
4. If `run_lives <= 0`: show run-over screen
5. Else: load next puzzle (seeded by `run_seed + run_depth`)

---

## What stays the same

- All existing puzzle UI (tiles, guess validation, hint button, one-away feedback, confetti, solved rows)
- Summary overlay is **skipped** — no per-puzzle summary in beskraj, just straight to next puzzle
- Name picker is **skipped** — no Firebase submission
- Settings overlay still accessible

---

## Out of scope (for now)

- Global leaderboard for beskraj runs
- Daily seeded beskraj run (a "Beskraj izazov")
- Multiplayer / async challenges
