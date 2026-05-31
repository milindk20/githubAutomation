#!/bin/bash

# --- CONFIGURATION ---
TARGET_DIR="${1:-.}"
# ---------------------

# Get absolute path of starting directory so we never get lost
START_DIR=$(pwd)
ABS_TARGET_DIR=$(realpath "$TARGET_DIR")

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Starting Git synchronization in: $ABS_TARGET_DIR${NC}"
echo "------------------------------------------------"

# Tell Git to temporarily trust all directories for this script run
export GIT_CEILING_DIRECTORIES="$ABS_TARGET_DIR"

# Find all .git folders
find "$ABS_TARGET_DIR" -type d -name ".git" | while read -r gitdir; do
    # Get the absolute path to the repository
    repo_dir=$(dirname "$gitdir")
    
    echo -e "\n${YELLOW}Checking repository: $(basename "$repo_dir")${NC}"
    
    # ALWAYS navigate using the full absolute path
    cd "$repo_dir" || continue

    # Check if the repository has a remote configured
    # Adding an override config flag to ignore safe directory checks just for this command
    if ! git -c safe.directory='*' remote | grep -q '.*'; then
        echo -e "${RED} No remote repository configured (or permission issue). Skipping.${NC}"
        cd "$START_DIR"
        continue
    fi

    # Fetch latest changes from remote (ignoring ownership safety checks)
    echo " Fetching from remote..."
    git -c safe.directory='*' fetch --all --prune --quiet 2>/dev/null

    # Get current branch
    current_branch=$(git -c safe.directory='*' symbolic-ref --short HEAD 2>/dev/null)
    
    if [ -z "$current_branch" ]; then
        echo -e "${RED} Head is detached. Skipping pull.${NC}"
        cd "$START_DIR"
        continue
    fi

    # Check for uncommitted changes
    has_changes=false
    if ! git -c safe.directory='*' diff-index --quiet HEAD --; then
        echo " Local changes detected. Stashing work..."
        git -c safe.directory='*' stash push -m "Auto-stash before auto-update" --quiet
        has_changes=true
    fi

    # Pull changes
    echo " Pulling latest changes for branch: $current_branch..."
    if git -c safe.directory='*' pull origin "$current_branch" --rebase --quiet; then
        echo -e "${GREEN} Successfully updated!${NC}"
    else
        echo -e "${RED} Error updating this repository. Check for conflicts.${NC}"
    fi

    # Pop stash if needed
    if [ "$has_changes" = true ]; then
        echo " Restoring your local changes..."
        git -c safe.directory='*' stash pop --quiet
    fi

done

# Navigate back to where the user started
cd "$START_DIR" || exit
echo -e "\n${GREEN}---- All repositories processed! ----${NC}"