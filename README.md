# Microbe Mayhem — Immune System Defense (Love2D prototype)

This is a small Love2D prototype created for the Microbe Mayhem concept (tower-defense style educational game).

Play notes
- Click on the grid to place the selected tower (cost shown in-game).
- Right-click toggles "resting", which increases nutrient generation.
- Keys: `1` = macrophage, `2` = neutrophil, `3` = T-cell (adaptive), `4` = B-cell (adaptive).
- Adaptive towers unlock after ~25 seconds to represent adaptive immunity timing.
- Press `Space` to manually spawn a new wave for testing.

Run

Install Love2D (https://love2d.org/) and run from the repository root:

```bash
love .
```

Files added
- `main.lua` — main game prototype
- `conf.lua` — window configuration

Design notes
- Innate towers (macrophage, neutrophil) are available immediately.
- Adaptive towers (T-cell, B-cell) unlock with time to illustrate immune timing.
- Nutrients simulate resource generation; resting increases nutrient gain.
- Pathogens (bacteria, viruses, fungi) vary in health and speed.

Next steps (suggestions)
- Add sound effects and sprites
- Add tutorial overlay explaining innate vs adaptive
- Implement better pathfinding & multiple lanes
- Add scoring and level progression
# Project Title

[One-sentence summary of your project]

## Biomedical Context

[Who/what this app or game is for]

## Quick Start Instructions

### Opening the Repository in GitHub Codespaces

[Instructions on how to open this repo in GitHub Codespaces]

### Running the Application

[Exact command(s) to run the app/game, e.g., `pip install streamlit` then `streamlit run app.py` or `DISPLAY=:0 love .`]

## Usage Guide

[Step-by-step explanation with screenshots or text]

- **Step 1:** [Description]
- **Step 2:** [Description]
- **Step 3:** [Description]

## Data Description (optional)

### Data Source

[Where your data came from]



## Project Structure

[Description of the project structure and organization]

