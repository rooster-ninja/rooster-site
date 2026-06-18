# rooster.ninja — Deployment Notes

## Deploy script
`~/claude-code/deploy_rooster.sh` — run this to deploy everything.

## What the deploy script does (in order)
1. `git pull` on rooster-site (Hugo source)
2. `hugo` — builds static site into `rooster-site/public/`
3. `quarto render` — re-renders ALL Jupyter notebooks to `notebooks/_site/` (must happen before S3 sync)
4. `aws s3 sync rooster-site/public/` → `s3://rooster.ninja/` (excludes `moon_sensors/calibration/*`)
5. `aws s3 sync notebooks/_site/` → `s3://rooster.ninja/moon_sensors/calibration/`
6. CloudFront invalidation on distribution `E2S74M6Y7DEL6D`

## Key directories
| Path | Purpose |
|---|---|
| `~/claude-code/rooster-site/` | Hugo site source |
| `~/claude-code/rooster-site/public/` | Hugo build output → S3 |
| `~/claude-code/notebooks/` | Quarto project (Jupyter notebooks) |
| `~/claude-code/notebooks/_site/` | Quarto render output → S3 |
| `~/claude-code/data/logs/` | Moon temp daily CSV logs |
| `~/claude-code/jupyter-env/` | Python venv with pandas, quarto deps |

## Jupyter notebooks — IMPORTANT
**Always run `quarto render` before deploying.** The deploy script does this automatically.
If adding a new notebook to the Quarto project, add it to `notebooks/_quarto.yml` nav so it
gets rendered and included in the S3 sync.

## Moon temp calibration
- Notebook: `notebooks/Moon_Temp_Calibration_Jupyter/sensor_offset_analysis.ipynb`
- Live at: `rooster.ninja/moon_sensors/calibration/Moon_Temp_Calibration_Jupyter/sensor_offset_analysis.html`
- Current offsets (ESP32 flash): ADC0 = 0, ADC1 = +16, ADC2 = −64 (adjusted 2026-06-15)
- Pass criterion: std(adc0−adc1) ≤ 4.0 mV AND std(adc0−adc2) ≤ 4.0 mV

## CloudFront
- Distribution ID: `E2S74M6Y7DEL6D`
- Propagation after invalidation: ~1–2 minutes
