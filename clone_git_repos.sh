





#gh repo list --limit 1000 --json nameWithOwner -q '.[] | .nameWithOwner' | while read -r repo; do gh repo clone "$repo"; done
# #!/bin/bash

# 1. Clone all repositories
gh repo list --limit 1000 --json nameWithOwner -q '.[] | .nameWithOwner' | while read -r repo; do
    gh repo clone "$repo"
done
