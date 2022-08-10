@echo off
SETLOCAL EnableDelayedExpansion

if not DEFINED CUCUMBER_REPO_PATH (
    echo '### The CUCUMBER_REPO_PATH is not set. Aborting'
    PAUSE
    exit
)

cd "%CUCUMBER_REPO_PATH%"

for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%i
git add features
for /f %%i in ('git diff --cached') do set CHANGES=%%i

if "%CHANGES%" == "" (

    for /f "delims=" %%i in ('git log --branches --not --remotes') do (
        set UNPUSHED_COMMITS=%%i
    )
    
    echo !UNPUSHED_COMMITS!

    if NOT [!UNPUSHED_COMMITS!] == [] (
        
        git log --branches --not --remotes

        echo '### Unpushed commits found, will push these to remote repository for devs to review.'

        PAUSE

        git push origin %CURRENT_BRANCH%

        PAUSE

        exit
    ) else (
        echo '### Nothing to save, aborting...'
    )
    PAUSE
    exit
)

git diff --cached

echo '### PLEASE REVIEW YOUR CHANGES ABOVE AND CONTINUE'

PAUSE

git branch

set /p BRANCH=READ-USER -Prompt "Name your changes (Jira-ref/name). Leave empty if current (%CURRENT_BRANCH%) one suffices."
set /p COMMENT=READ-USER -Prompt "Summary of your changes (max 1 line)"

if [%BRANCH%] == [] (
    set BRANCH=%CURRENT_BRANCH%
)

echo "### About to make a commit with message '%COMMENT%' on branch '%BRANCH%'"
PAUSE

git branch %BRANCH%
git checkout "%BRANCH%"
git commit -m "%COMMENT%"
git push origin %BRANCH%

echo '### Please use the above pull request link to create a pull request for developers to review.'

PAUSE