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
deactivate

aws s3 sync "$SITE_DIR/public/" s3://rooster.ninja/ --delete --exclude "moon_sensors/calibration/*"
aws s3 sync "$NOTEBOOKS_DIR/_site/" s3://rooster.ninja/moon_sensors/calibration/
aws cloudfront create-invalidation --distribution-id E2S74M6Y7DEL6D --paths "/*"
echo "rooster.ninja deployed and CloudFront cache invalidated"
