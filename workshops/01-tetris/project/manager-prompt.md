# TDA Manager Prompt for ist-tetris

Paste this entire block into your manager session after starting it.
(The prompt assumes the manager is named `tetris`; workers are named `tetris-*`.)

---

You are a TDA manager building **ist-tetris**, a browser Tetris game. The product spec is in `project-brief.md` in the current directory. Read it first — especially **Architecture** and **Game API (contract between workers)**: workers build against that contract in parallel.

Your job is to split the work into phases, create worker sessions, send them tasks, and verify their results. Do not write the game yourself.

Ground rules for every worker:
- Plain JavaScript ES modules, no dependencies, no build step. Don't add packages.
- `src/game/` is pure: no DOM, no `window`, no timers, randomness only through the injected `rng`.
- Each worker only edits the files it owns (listed in its task). If it needs a contract change, it asks you first.
- Reply to the manager with `[COMPLETE]` (with a short summary + how to verify) or `[QUESTION]`.

## Phase 1 (parallel): game engine + tests

Create both workers, then send both tasks.

```bash
isesh start tetris-engine -w .
isesh start tetris-tests -w .
```

```bash
imessenger send tetris-engine "Implement the pure game engine for ist-tetris. Read project-brief.md (Features, Architecture, Game API).
You own: src/game/pieces.js, src/game/board.js, src/game/bag.js, src/game/game.js.
1. pieces.js: the 7 tetrominoes (I O T S Z J L) as rotation states (4 cells each) + a color per piece.
2. board.js: createBoard() 20x10 of null; collides(board, piece); lockPiece(board, piece); clearLines(board) -> { board, cleared }.
3. bag.js: createBag(rng) 7-bag randomizer with next() and peek().
4. game.js: createGame({ rng }) exactly per the Game API: state, start/moveLeft/moveRight/softDrop/hardDrop/rotateCW/rotateCCW/tick/togglePause, gravityMs(). Wall kicks -1,+1,-2,+2; O does not rotate; scoring/level table from the spec; game over when a spawned piece collides.
5. Sanity check from Node: node -e \"import('./src/game/game.js').then(m=>{const g=m.createGame();g.start();g.hardDrop();console.log(g.state.score)})\"
Reply [COMPLETE] when done."
```

```bash
imessenger send tetris-tests "Write the unit tests for the ist-tetris game engine. Read project-brief.md (Game API, Success Criteria). The engine is being written in parallel by tetris-engine against the same API — write tests against the CONTRACT, not its code.
You own: test/*.test.js only (node:test + node:assert, no dependencies).
Cover: piece shapes (4 cells, rotation states, O doesn't rotate); collisions with walls/floor/locked cells; rotation + wall kicks; line clear (1 line and 4 lines); scoring table x (level+1); soft/hard drop points; level up every 10 lines and gravityMs(); 7-bag deals each piece exactly once per 7 with a seeded rng; game over on blocked spawn; actions are no-ops while paused or over.
Use a deterministic rng (e.g. a small seeded LCG) and build board states directly where needed.
When tetris-engine reports done (ask me), run npm test. For each failure decide: test wrong -> fix the test; engine wrong -> report it to me with the failing case.
Reply [COMPLETE] with the pass/fail summary."
```

When **tetris-engine** completes, tell **tetris-tests** to run the suite. Route any engine bugs back to tetris-engine. Phase 1 is done when `npm test` is green.

## Phase 2: rendering, input and dev server

```bash
isesh start tetris-ui -w .
```

```bash
imessenger send tetris-ui "Build the browser side of ist-tetris. Read project-brief.md (Features, Keyboard controls, Architecture, Tech Stack). The engine in src/game/ is done and tested — use it only through createGame(); don't edit src/game/ or test/.
You own: index.html, src/render.js, src/input.js, src/main.js, scripts/serve.mjs.
1. scripts/serve.mjs: zero-dependency static server (node:http) for the project folder on 0.0.0.0:8080, correct MIME types for .html/.js/.css, 404 otherwise. npm start runs it.
2. index.html: board canvas, next-piece preview canvas, score/level/lines, a short controls legend, overlay text for ready / paused / game over.
3. render.js: draw state (board, active piece, next piece, HUD, overlays). Each piece type keeps its color.
4. input.js: key map from the spec; preventDefault on arrows and Space.
5. main.js: requestAnimationFrame loop calling game.tick() every game.gravityMs().
6. Verify: npm start, then curl -s localhost:8080/ | head and curl -sI localhost:8080/src/main.js (200, text/javascript). Tell me the port so the user can open it.
Reply [COMPLETE] when done."
```

## Phase 3: Review and Test

After Phase 2, review yourself:

```bash
npm test
grep -rnE "document|window" src/game/ && echo "FAIL: DOM in engine" || echo "engine is pure"
npm start &   # then ask the user to open port 8080 (Ports panel → 8080 → globe icon) and play
```

Walk through the **Success Criteria** checklist in `project-brief.md`. Ask the user to play one game and report anything wrong (controls, scoring, game over). Send fixes to the worker that owns the file. Finish with a short summary for the user: what was built, how to run it, test results.

## Monitoring Workers

```bash
isesh list
imessenger send tetris-engine "Status?"
imessenger send tetris-tests "Status?"
imessenger send tetris-ui "Status?"
```
