@echo off

cd %CUCUMBER_REPO_PATH%

for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%i

start "" "https://github.com/ministryofjustice/check-financial-eligibility/compare/main...ministryofjustice:check-financial-eligibility:%CURRENT_BRANCH%?expand=1"
