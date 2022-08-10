#!/bin/bash

MAIN_BRANCH="cucumber"

if [[ ! -z "$CUCUMBER_REPO_PATH" ]]; then

    cd "$CUCUMBER_REPO_PATH"

    git branch

    echo "Which existing branch would you like to open? Enter to use default."
    read CHOSEN_BRANCH

    if [[ -z $CHOSEN_BRANCH ]]; then
        CHOSEN_BRANCH=$MAIN_BRANCH
    fi

    echo "### Checking out ${CHOSEN_BRANCH}"

    git stash
    git fetch origin
    git checkout $MAIN_BRANCH
    git pull origin $MAIN_BRANCH
    git checkout $CHOSEN_BRANCH

    git branch

    code "" "${CUCUMBER_REPO_PATH}/features" | exit
else
    read -p "### The CUCUMBER_REPO_PATH is not set. Aborting"
fi