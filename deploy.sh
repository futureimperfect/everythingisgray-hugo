#!/bin/sh

THEME=cactus

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
if [ -z "$THEME" ]; then
    hugo
else
    hugo -t "$THEME"
fi

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="Rebuilding site on $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master
