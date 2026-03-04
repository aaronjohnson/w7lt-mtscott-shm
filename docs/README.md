# docs/

Technical documentation for the W7LT Mt. Scott SHM project.

## LaTeX sources

| File | Status | Description |
|---|---|---|
| `mt_scott_mast_final.tex` | Complete | Mast plumb-correction analysis: rotated-bearing geometry, wind loading, field procedure |
| `pole_monitoring.tex` | Complete | SHM system design: sensors, MQTT architecture, Elixir/Phoenix stack |
| `qex_preprint_v0.1.0.tex` | Draft | QEX article preprint — mast correction (pending Trip 2 confirmation measurements) |

## BOM

| File | Description |
|---|---|
| `bom/w7lt_bom_v1.0.0.xlsx` | DigiKey order, ~$710 total, four sensor tiers + hub + power |

## Build

Requires a standard TeX Live installation (`texlive-latex-extra`, `texlive-science`).

```bash
cd docs
pdflatex mt_scott_mast_final.tex
pdflatex pole_monitoring.tex
pdflatex qex_preprint_v0.1.0.tex
```

## Notes

- `qex_preprint_v0.1.0.tex` is a working draft. The label `v0.1.0` will advance
  to `v1.0.0` after Trip 2 measurements confirm pipe OD and bracket standoff gap.
- Do not submit to QEX until checking ARRL prior-publication policy with the editor.
  The ARRL publication release requires that material has not been previously
  published; confirm whether a public GitHub draft constitutes prior publication
  before signing the release form.

