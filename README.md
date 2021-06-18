# git-mover
an script to move a git repo between two git managers (For now only for GitLab)

some times you are migrating between two gitlab or other git manager instances so you need it :)

## requirements
You should have `jq, git, curl` Ready

## How to run
1. Change variables (`env.sh` file)
2. Run
```bash
chmod +x ./mover.sh
./mover.sh <Your Repo address>
```

## TODO
- [x] Create another script do it for all repos (in a loop)
