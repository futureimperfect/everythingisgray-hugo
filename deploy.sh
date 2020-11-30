#!/bin/sh

ACTOR=futureimperfect
HUGO=hugo
HUGO_VERSION=0.79.0
TARGET_REPO=futureimperfect/futureimperfect.github.io
THEME=cactus

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)

# If a command fails then the deploy stops.
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

REF="$1"
if [ -z "$1" ]; then
    REF="master"
fi

if [ -z "$TOKEN" ]; then
    TOKEN="$GITHUB_TOKEN"
fi

if [ -z "$GITHUB_ACTOR" ]; then
    GITHUB_ACTOR="$ACTOR"
fi

if [ -z "$TARGET_REPO" ]; then
    TARGET_REPO="$GITHUB_REPOSITORY"
fi

if [ "$CI" = "true" ]; then
    cd "$GITHUB_WORKSPACE" || exit 1
    REMOTE_REPO="https://${TOKEN}@github.com/${TARGET_REPO}.git"
else
    REMOTE_REPO="git@github.com:futureimperfect/futureimperfect.github.io.git"
fi

# Themes use submodules. We need them. Don't include the GitHub Pages repo in the updates, though.
git -c submodule."futureimperfect/futureimperfect.github.io".update=none submodule update --init --recursive

if [ "$CI" = "true" ]; then
    echo "Installing Hugo..."
    curl -fsSL "https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" > hugo.tar.gz && tar -zxvf hugo.tar.gz
    HUGO=./hugo
elif [ -z "$(command -v hugo)" ]; then
    echo "You must install Hugo before continuing."
    exit 1
fi

# Print the Hugo version.
echo "Hugo version: " && "$HUGO" version

# Build the project.
if [ -z "$THEME" ]; then
    "$HUGO"
else
    "$HUGO" -t "$THEME"
fi

# Go to the public folder.
if [ "$CI" = "true" ]; then
    cd "${GITHUB_WORKSPACE}/public"
else
    cd "${SCRIPT_DIR}/public"
fi

# Remove the existing public .git dir.
rm -rf .git

# Create a new Git repo.
git init
git config user.name "$GITHUB_ACTOR"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# Add changes to git.
git add .

# Set the commit message.
msg="Rebuilding site on $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi

# Commit changes.
git commit -m "$msg"

# Push source and build repos.
git push --force "$REMOTE_REPO" master:"${REF}"

# Go back to the original directory.
cd -

exit 0
