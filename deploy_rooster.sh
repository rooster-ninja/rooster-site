#!/bin/bash
set -e

SITE_DIR=$HOME/claude-code/rooster-site
NOTEBOOKS_DIR=$HOME/claude-code/notebooks
JUPYTER_ENV=$HOME/claude-code/jupyter-env

cd "$SITE_DIR"
git pull
hugo

cd "$NOTEBOOKS_DIR"
source "$JUPYTER_ENV/bin/activate"
quarto render Moon_Temp_Calibration_Jupyter/sensor_offset_analysis.ipynb --execute
quarto render moon_sensors/overview/moon_temp_overview.ipynb
deactivate

aws s3 sync "$SITE_DIR/public/" s3://rooster.ninja/ --delete --exclude "moon_sensors/*" --exclude "site_libs/*"
aws s3 cp "$SITE_DIR/public/moon_sensors/index.html" s3://rooster.ninja/moon_sensors/index.html
aws s3 sync "$NOTEBOOKS_DIR/_site/" s3://rooster.ninja/moon_sensors/calibration/ --exclude "moon_sensors/*"
aws s3 sync "$NOTEBOOKS_DIR/_site/moon_sensors/results/" s3://rooster.ninja/moon_sensors/results/
aws s3 sync "$NOTEBOOKS_DIR/_site/moon_sensors/overview/" s3://rooster.ninja/moon_sensors/overview/
aws s3 sync "$NOTEBOOKS_DIR/_site/site_libs/" s3://rooster.ninja/site_libs/

# Set Content-Disposition: attachment on all PDF assets so iOS Safari downloads rather than previews
for pdf in   skunk_werks/giga_ranger/assets/AN1200.29_Introduction_to_Ranging_SX1280.pdf   skunk_werks/giga_ranger/assets/AN1200.50_SX1280_Ranging_Protocol.pdf   skunk_werks/giga_ranger/assets/Wolf_2019_WPNC2019_Benchmark_SX1280_Cronen.pdf   skunk_werks/giga_ranger/assets/GigaRangerOverview_003.pdf; do
  aws s3 cp "s3://rooster.ninja/$pdf" "s3://rooster.ninja/$pdf"     --metadata-directive REPLACE     --content-type "application/pdf"     --content-disposition "attachment"
done

aws cloudfront create-invalidation --distribution-id E2S74M6Y7DEL6D --paths "/*"
echo "rooster.ninja deployed and CloudFront cache invalidated"
