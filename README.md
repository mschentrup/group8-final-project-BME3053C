# Microbe Mayhem — Immune System Defense

An educational Love2D (LÖVE) tower-defense prototype that visualizes innate and adaptive immune responses: players place immune cells to defend a bloodstream against waves of pathogens. Intended for undergraduate students and instructors as a lightweight demo to illustrate immune-system concepts and trade-offs (resource management, innate vs adaptive timing, tumor-specific responses).

## Short biomedical context
Who this is for:
- Biology / immunology students as an interactive learning aid.
- Educators looking for a simple demo to show innate vs adaptive immune timing and cell functions.
- Developers exploring LÖVE game prototypes with biomedical themes.

Learning goals:
- Visualize differences between innate and adaptive responses.
- Demonstrate resource-trade-offs (nutrients) and timing (adaptive unlock).
- Show specialized behaviors needed to handle tumor-like enemies.

## Quick start

Clone the repo, then run locally (LÖVE required):

1. Clone:
   ```
   git clone https://github.com/mschentrup/group8-final-project-BME3053C.git
   cd mschentrup/group8-final-project-BME3053C
   ```

2. Run:
   - On Windows (double-click): `run-game.bat`  
   - From terminal (Windows/macOS/Linux) with LÖVE installed:
     ```
     love .
     ```

Notes:
- LÖVE 11.x is required: https://love2d.org
- Codespaces and other headless environments do not provide an X server by default; see the Codespaces section below.

### Opening in GitHub Codespaces
You can open the repo in GitHub Codespaces to edit code and run non-GUI tasks, but LÖVE requires a graphical display and will not run in a default Codespace.

To open:
1. Go to the repository page on GitHub.
2. Click the green "Code" button → "Codespaces" → "New codespace".
3. Use the Codespaces terminal for editing, building, or running CLI-only checks.

Attempting to run the game in Codespaces:
- In the Codespaces terminal you could run `love .`, but the LÖVE window will fail to open because Codespaces is headless (no X server). To test the GUI you must run locally or set up an X server/forwarding which is beyond the scope of this repo.

## Usage guide (step-by-step)

Step 1: Start the game
- Run `love .` from the repository root (or double-click `run-game.bat` on Windows).

Step 2: Read the HUD
- Bottom HUD shows: Time, Nutrients, Wave number, Health, Resting status, current selection, and key help.
- Right-side panel shows the selected cell type and stats (Cost, Range, Rate, Damage, and special effects).

Step 3: Place immune cells
- Use the mouse to select a cell and left-click a valid tile outside the bloodstream corridor.
- Right-click a placed cell to toggle Resting (increases nutrients gain but disables action while resting).

Step 4: Manage nutrients and timing
- Nutrients accrue over time. Resting boosts nutrient generation; use early resting to save for stronger adaptive cells.
- Adaptive cells unlock after around ~25 seconds of play: T-cell, B-cell, Cytotoxic T. NK and innate cells are available immediately.

Step 5: Spawn waves and respond
- Press Space to spawn the next wave.
- If enemies reach the goal you lose health. Clear waves to win.

Controls quick reference:
- Mouse left-click: place a cell
- Mouse right-click: toggle Resting
- Keys:
  - 1: Macrophage (innate)
  - 2: Neutrophil (innate)
  - 3: T-cell (adaptive; unlocks after ~25s)
  - 4: B-cell (adaptive; unlocks after ~25s)
  - 5: Cytotoxic T (adaptive; needed for tumor enemies)
  - 6: NK (innate; can damage tumors)
  - Space: Spawn wave
  - R: Restart
  - T: Spawn tumor enemy (debug); Shift+T spawns five

(example screenshots: place images in `docs/screenshots/` and replace links below)
- Screenshot of HUD and placement: docs/screenshots/hud.png
- Screenshot of wave in progress: docs/screenshots/wave.png

## Gameplay summary
- Macrophage: engulfs low-HP pathogens (heal + nutrient), AoE slow.
- Neutrophil: fast burst shooter but limited durability.
- T-cell: strong projectile (adaptive).
- B-cell: produces antibody particle projectiles (adaptive).
- Cytotoxic T: required to kill tumor enemies.
- NK: can kill tumor enemies without prior sensitization (innate).
- Pathogens follow a grid-aligned orthogonal path; towers cannot be placed within the corridor.

## Data description (optional)
This project does not use external biomedical datasets. All gameplay parameters and enemy definitions are created for educational/demo purposes within the code (main.lua). If you add or import datasets (e.g., biological models, images), document their source and license here.

## License & citation
- Add your license file (e.g., LICENSE). If none is present, consider adding an OSI-compatible license such as MIT or BSD.
- To cite this project, include author names, repository URL, and commit SHA.

## Project structure (outline)
Below is a suggested structure — update with `git ls-files` output for accuracy.

- README.md — (this file) overview, quick start, usage
- main.lua — core gameplay prototype (game loop, entities, rules)
- conf.lua — LÖVE window config
- run-game.bat — Windows helper to run LÖVE
- docs/ — (optional) screenshots, tutorial overlay assets
- assets/ — (optional) sprites, sounds (if added)
- LICENSE — (optional) license file
- .gitignore

To create an automatic file listing to paste here:
```
git ls-files | sed 's/^/ - /'
```

## Design notes & next steps
- Innate towers available immediately; adaptive towers unlock with time to illustrate immune timing.
- Suggested enhancements: add sound effects and sprites, tutorial overlay, multiple lanes and improved pathfinding, scoring and level progression.

## Development / Contributing
- Fork the repo and open a PR. For substantial changes, open an issue to discuss design first.
- Coding style: keep Lua modules simple; keep gameplay config in a single place in main.lua for easy tuning.

## Known limitations
- Codespaces/dev containers cannot run LÖVE's GUI by default (no X server).
- This is a prototype: many scaffolds listed (Eosinophil, Dendritic, Helper T, Regulatory T) are placeholders for future work.

---

If you want, I can:
- Generate a complete file-list from the repository and populate the Project structure section for you (I can fetch repository file list if you want me to).
- Create placeholder screenshot files and a small "docs" folder layout.
- Open a PR that replaces README.md with the proposed version (tell me the repo owner and confirm you'd like me to push).
