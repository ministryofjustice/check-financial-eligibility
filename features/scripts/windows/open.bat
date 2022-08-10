@echo off
SETLOCAL EnableDelayedExpansion

SET MAIN_BRANCH=cucumber

if DEFINED CUCUMBER_REPO_PATH (

    cd %CUCUMBER_REPO_PATH%

    git branch

    SET /p CHOSEN_BRANCH="Which existing branch would you like to open? Enter to use default."

    if [!CHOSEN_BRANCH!] == [] (
        SET CHOSEN_BRANCH=%MAIN_BRANCH%
    )

    echo ### Checking out !CHOSEN_BRANCH!

    git stash
    git fetch origin
    git checkout %MAIN_BRANCH%
    git pull origin %MAIN_BRANCH%
    git checkout "!CHOSEN_BRANCH!"

    git branch

    code "" "%CUCUMBER_REPO_PATH%\features" | exit
) else (
    echo "### The CUCUMBER_REPO_PATH is not set. Aborting"
    PAUSE
)