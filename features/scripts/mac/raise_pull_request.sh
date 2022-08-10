#!/bin/bash

cd $CUCUMBER_REPO_PATH

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

open "https://github.com/forceedge01/check-financial-eligibility/compare/main...forceedge01:check-financial-eligibility:${CURRENT_BRANCH}?expand=1"
