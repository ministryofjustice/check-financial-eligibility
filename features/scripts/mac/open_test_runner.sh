#!/bin/bash

cd $CUCUMBER_REPO_PATH

URL="https://app.circleci.com/pipelines/github/ministryofjustice/check-financial-eligibility?branch="
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

git push
open "${URL}${CURRENT_BRANCH}"
