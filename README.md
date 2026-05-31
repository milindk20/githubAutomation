# Git Repository Automation Scripts

This repository contains a pair of Bash utility scripts designed to automate the bulk downloading and maintenance of your GitHub ecosystems. Together, they allow you to clone your entire GitHub footprint and keep all local copies perfectly synchronized with their remotes, handling edge cases like detached heads or uncommitted local work automatically.

---

## 🚀 The Scripts

### 1. `clone_git_repos.sh`
Uses the GitHub CLI (`gh`) to fetch up to 1000 repositories from your account (including organization repositories you have access to) and clones them into your current working directory.

### 2. `update_git_repos.sh`
Iterates through all subdirectories of a given target path, identifies active Git repositories, and securely updates them. It features automated error boundary handling, including safety-bypass configurations for external mounts (like `/mnt/`), automatic local work stashing, and conflict detection.

---

## 📊 Workflow Execution Chart

```text
==========================================================================
                     GIT AUTOMATION SCRIPT FLOW
==========================================================================

 [ clone_git_repos.sh ]                   [ update_git_repos.sh ]
          |                                          |
   Authenticate via                          Accept Target Dir
    GitHub CLI (gh)                        (Defaults to current ".")
          |                                          |
Fetch up to 1000 Repos                     Scan for .git Directories
   (nameWithOwner)                                   |
          |                                  Loop through each
     While Loop                                 Repository
    Through List                                     |
          |                            /-------------+-------------\
    Execute Clone                      |                           |
  "gh repo clone X"            Has Remote? No              Has Remote? Yes
          |                            |                           |
          v                    [Skip Repo]                         v
   [Task Complete]                     |                   Fetch Remote & Prune
                                       |                           |
                                       |                   Is HEAD Detached?
                                       |                    /-------------\
                                       |                  Yes              No
                                       |                   |               |
                                       |              [Skip Repo]          v
                                       |                           Check Local Changes
                                       |                            /-------------\
                                       |                          Yes              No
                                       |                           |               |
                                       |                     [Auto-Stash]          |
                                       |                           \-------+-------/
                                       |                                   |
                                       |                             git pull --rebase
                                       |                                   |
                                       |                            Pull Successful?
                                       |                            /-------------\
                                       |                          Yes              No
                                       |                           |               |
                                       |                    [Print Success]  [Print Error]
                                       |                           \-------+-------/
                                       |                                   |
                                       |                           Popped Stash? (If any)
                                       \-------------------+---------------/
                                                           |
                                                   Move to Next Repo
                                                           |
                                                    [Loop Finished]
                                                           |
                                               Return to Starting Directory




**## 🛠 Prerequisites**
Before running these scripts, ensure your environment has the following installed and configured:

GitHub CLI (gh): Required for the cloning script. Install guide here.

Authentication: Run gh auth login to authenticate the CLI with your GitHub profile before running the clone utility.

Realpath Utility: Typically pre-installed on Linux distributions (GNU coreutils), used by the updater to safely map absolute folder paths.


## 💻 Usage Instructions

1. Cloner Setup
Move to the directory where you want your projects saved, and execute the script:

Bash
chmod +x clone_git_repos.sh
./clone_git_repos.sh
2. Updater Setup
You can run the update script without arguments to update the current folder, or target a specific path directly:

Update current folder:

Bash
chmod +x update_git_repos.sh
./update_git_repos.sh
Update a target path:

Bash
./update_git_repos.sh /mnt/MyDisk/Documents/Projects_Github
⚙️ Advanced Features Handled
Safe Directory Bypass (-c safe.directory='*'): Fixes the common strict ownership error blocks triggered when Git repos live on external drives or mounted volumes (/mnt/...).

Auto-Stash Recovery: If you have uncommitted changes in a project, the script generates a temporary "Auto-stash before auto-update" save point, pulls the remote updates via rebase, and cleanly restores your local workspace seamlessly.

Head Detachment Protection: Identifies states where you are checking out specific historical commits rather than active branches, preventing breaking pull operations.