#!/bin/bash

if [[ -z $CUCUMBER_REPO_PATH ]]; then
    read -p '### The CUCUMBER_REPO_PATH is not set. Aborting. Press any key to exit.'
    exit
fi

cd $CUCUMBER_REPO_PATH

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git add features
CHANGES=$(git diff --cached)

if [[ -z $CHANGES ]]; then

    UNPUSHED_COMMITS=$(git log --branches --not --remotes)
    
    echo "$UNPUSHED_COMMITS"

    if [[ ! -z $UNPUSHED_COMMITS ]]; then
        
        git log --branches --not --remotes

        echo '### Unpushed commits found, will push these to remote repository for devs to review.'
        read -p 'Press any key to continue...'

        git push origin $CURRENT_BRANCH

        read -p

        exit
    else
        read -p '### Nothing to save, aborting. Press any key to continue...'
    fi
    exit
fi

echo '### PLEASE REVIEW YOUR CHANGES'
read -p 'Press any key to continue...'

git diff --cached

git branch

echo "Name your changes (Jira-ref/name). Leave empty if current (${CURRENT_BRANCH}) one suffices."
read BRANCH
echo "Summary of your changes (max 1 line)"
read COMMENT

if [[ -z $BRANCH ]]; then
    BRANCH=$CURRENT_BRANCH
fi

echo "### About to make a commit with message '$COMMENT' on branch '$BRANCH'."
read -p 'Press any key to continue...'

git branch $BRANCH
git checkout "$BRANCH"
git commit -m "$COMMENT"
git push origin $BRANCH

echo '### Please use the above pull request link to create a pull request for developers to review.'
read -p 'Press any key to continue...'
