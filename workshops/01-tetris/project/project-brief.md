# ist-tetris - Product Specification

## Overview

**ist-tetris** is a classic falling-block puzzle game that runs in the browser.
It is plain HTML + JavaScript (ES modules) — **no framework, no bundler, no build
step** — so it starts instantly inside a GitHub Codespace and the game logic can
be unit-tested with Node's built-in test runner.

## Target User

Anyone who opens the Codespace's forwarded port in a browser and wants to play a
correct, responsive game of Tetris with a keyboard.

## Features

| Feature | Requirement |
|---------|-------------|
| Board | 10 columns × 20 visible rows. Cells are empty or hold a piece color. |
| Tetrominoes | All 7: `I O T S Z J L`, each with its own color. |
| Randomizer | "7-bag": shuffle all 7 pieces, deal them out, repeat. Injectable RNG so tests are deterministic. |
| Movement | Left, right, soft drop (1 row), hard drop (to the bottom, locks immediately). |
| Rotation | Clockwise and counter-clockwise. If the rotated piece collides, try simple wall kicks: shift by −1, +1, −2, +2 columns (in that order); if all collide, the rotation is ignored. `O` does not rotate. |
| Gravity | The active piece falls one row per tick. Tick interval depends on level (see Scoring). |
| Locking | When a piece can't move down on a gravity tick (or after a hard drop), it locks into the board and the next piece spawns. |
| Line clear | Full rows are removed; rows above shift down. |
| Score / level | Lines cleared at once → points × (level + 1): 1 → 40, 2 → 100, 3 → 300, 4 → 1200. Soft drop: +1 per row; hard drop: +2 per row. Level = floor(totalLines / 10), starting at 0. Gravity interval = max(100, 800 − level × 70) ms. |
| Next piece | A preview of the next piece is shown beside the board. |
| Game over | If a newly spawned piece collides immediately, the game is over. Show "Game over", the final score, and "Press Enter to restart". |
| Pause | `P` toggles pause; gravity stops while paused. |

### Keyboard controls

| Key | Action |
|-----|--------|
| ← / → | Move left / right |
| ↓ | Soft drop |
| Space | Hard drop |
| ↑ or X | Rotate clockwise |
| Z | Rotate counter-clockwise |
| P | Pause / resume |
| Enter | Start / restart after game over |

Arrow keys and Space must not scroll the page (`preventDefault`).

## Architecture

The core is **pure logic with no DOM access**, so it runs in Node tests and the browser alike.

```
ist-tetris/
├── index.html            # page: <canvas> board, next-piece preview, score/level/lines, help text
├── src/
│   ├── game/             # PURE — no DOM, no timers, no Math.random calls without injection
│   │   ├── pieces.js     # 7 tetromino shapes (rotation states) + colors
│   │   ├── board.js      # createBoard(), collides(board, piece), lockPiece(), clearLines()
│   │   ├── bag.js        # createBag(rng) → { next(), peek() }  (7-bag)
│   │   └── game.js       # createGame({ rng }) → state + actions (below)
│   ├── render.js         # draws a game state onto canvases
│   ├── input.js          # keyboard → game actions
│   └── main.js           # wires game + render + input + the gravity loop (requestAnimationFrame)
├── test/                 # node:test files: *.test.js
├── scripts/
│   └── serve.mjs         # tiny zero-dependency static file server (node:http)
└── package.json          # npm start / npm test (already provided)
```

### Game API (contract between workers)

`src/game/game.js` exports `createGame({ rng = Math.random } = {})` returning an object with:

- `state` (read-only snapshot getter or plain object) containing:
  `board` (20 rows × 10 cols, `null` or a color string), `active` (`{ type, rotation, x, y }`),
  `next` (piece type), `score`, `lines`, `level`, `status` (`'ready' | 'playing' | 'paused' | 'over'`)
- actions: `start()`, `moveLeft()`, `moveRight()`, `softDrop()`, `hardDrop()`,
  `rotateCW()`, `rotateCCW()`, `tick()` (one gravity step), `togglePause()`
- `gravityMs()` → current gravity interval for the level

Actions are no-ops unless `status === 'playing'` (except `start` and `togglePause`).
The browser loop calls `tick()` every `gravityMs()`; tests call `tick()` directly.

## Tech Stack

- **Language:** JavaScript (ES modules), JSDoc comments welcome; no TypeScript, no build
- **Runtime:** any modern browser; Node.js 22+ for tests and the dev server
- **Tests:** `node:test` + `node:assert` (built in) — `npm test`
- **Dev server:** `npm start` → `scripts/serve.mjs` serving the project folder on
  **port 8080**, bound to `0.0.0.0`. In a Codespace, port 8080 is auto-forwarded:
  open it from the **Ports** panel (globe icon) or the "Open in Browser" notification.
- **Dependencies:** none (no `npm install` needed)

## Success Criteria

- [ ] `npm test` passes with tests for: piece shapes (4 cells each, 4 rotation states except `O`), collision with walls/floor/locked cells, rotation + wall kicks, line clear (single and tetris), scoring table × level, level-up every 10 lines, 7-bag deals each piece exactly once per 7, hard drop scoring, game over on blocked spawn
- [ ] `npm start` serves the game on port 8080 and the page loads with no console errors
- [ ] All 7 tetrominoes appear, with distinct colors
- [ ] Keyboard controls work as listed; arrow keys / Space don't scroll the page
- [ ] Next piece preview is correct (matches the piece that spawns next)
- [ ] Score, level and lines update live; gravity speeds up with level
- [ ] Game over screen shows the final score; Enter restarts
- [ ] `src/game/` contains no DOM or `window` references
