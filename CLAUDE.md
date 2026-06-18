# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an R-based ecological research project analyzing particulate matter (PM) deposition on leaves at urban forest edges in the UNE (Urban-Natural Edge) study system. Data were collected across sites varying in urbanization level (urban/rural by distance from Boston and by % impervious surface area, %ISA) and position (edge at 0m vs. interior at 90m distance from edge).

## Running the Code

These are R Markdown (`.Rmd`) files intended to be run interactively chunk-by-chunk in RStudio, not knitted end-to-end. Run chunks in the order indicated by the startup section headers ("run this chunk FIRST", "run this chunk SECOND", etc.).

To render a full report:
```r
rmarkdown::render("2021_UNE_PM_Comp.Rmd")
rmarkdown::render("2021_UNE_LeafSEM.Rmd")
```

## File Paths

Data files live in Dropbox, **not** in this git repo (they are `.gitignore`d). The path variables at the top of each `.Rmd` must point to the correct Dropbox location. When running on a new machine, update the `dropbox` variable in the startup chunk:

```r
dropbox <- "/Users/emmadaily/BOSTON UNIVERSITY Dropbox/Emma Daily/Lab Files/Projects/UNE/Particulate Matter Project/Daily PM Analysis/RCode"
```

- `PMComp/csvs/` — input CSVs for `2021_UNE_PM_Comp.Rmd`
- `LeafSEM/csvs/` — input CSVs for `2021_UNE_LeafSEM.Rmd`

## Architecture

### `2021_UNE_PM_Comp.Rmd` — PM Composition Analysis

Compares elemental composition of foliar (leaf-captured) PM vs. ambient (passive sampler) PM across urbanization gradients and edge/interior positions.

**Chunk execution order:**
1. **Startup** — loads libraries, sets paths, reads `LeafPMComp.csv` and `AmbientPM.csv`, defines helper functions (`data_summary`, `stderr`, `ci95_median_boot`)
2. **Grouping Elements** — adds derived columns (`cations`, `metals`, `traffic`, `CN`) to both `FoliarPMCompxUNESites` and `AmbientPMCompxUNESites`. **Must re-run the startup chunk before re-running this chunk**, and re-run the entire chunk rather than individual lines (column indices are position-dependent)
3. **Combining Ambient and Foliar** — merges the two dataframes on shared element columns, adds `particle_source` label

**Key stats used:** ART ANOVA (non-parametric aligned-ranks), Kruskal-Wallis, Dunn post-hoc tests, nested models (site as random effect, tree/sampler nested within site), GLMMs via `glmmTMB`

**Output CSVs in this repo:**
- `allPM_AvF_kw_pvals.csv` — Kruskal-Wallis p-values for ambient vs. foliar comparisons by element and site group
- `allPM_AvF_art_pvals.csv` — ART ANOVA p-values for same comparisons

### `2021_UNE_LeafSEM.Rmd` — Leaf SEM & PM Loading Analysis

Analyzes scanning electron microscopy (SEM) data on stomatal occlusion, particle types, hyphal concentration, wax, and leaf PM loading.

**Primary datasets read in:**
- `LeafSEM.csv` — stomatal occlusion and SEM metrics per leaf image
- `LeafPM.csv` — gravimetric foliar PM2.5/PM10 per leaf sample (subsetted to Period 2)
- `Passive_Samplers.csv` — ambient PM2.5/PM10 from passive samplers (subsetted to edge [0m] and interior [90m])
- `UNE_Sites.csv` — site-level metadata (ISA, distance to Boston, urbanization category)

**Transformation decisions** (documented in startup section): variables are log-, sqrt-, or untransformed based on normality tests; non-normalizable variables use non-parametric tests. The transformation used for each variable is noted in comments in the startup chunk.

**Key categorical predictors:**
- `urb_cat_dist` — urban/rural by distance from Boston
- `urb_cat_isa` — urban/rural by %ISA
- `dfe` — distance from edge (0m = edge, 90m = interior), treated as a factor

## Key Shared Patterns

- `UNE_site` is the join key between all datasets and `UNE_Sites.csv`
- Both files define an identical `data_summary()` function (calculates mean ± SE by group using `dplyr`)
- Figures use `ggplot2` + `cowplot`; multi-panel assembly uses `gridExtra` and `gtable`
- Loops are used heavily to run the same stat/figure pipeline across all elements or response variables
- `recolorize::readImage()` is used to read in pre-made legend `.png` files from the csvs directory
