# git-mover
an script to move a git repo between two git managers (For now only for GitLab)

some times you are migrating between two gitlab or other git manager instances so you need it :)

## requirements
You should have `jq, git, curl` Ready

## How to run
1. Change variables (`env.sh` file)
2. 1. Run for one repo
```bash
chmod +x ./mover.sh
./mover.sh <Your Repo address>
```
2. 2. run for all repos
```bash
./move-all.sh
```

## TODO
- [x] Create another script do it for all repos (in a loop)
- [x] Variables from `env.sh` are not working (source command will solve it I think) [it should work now]
- [ ] Move merge requests if it's posible
