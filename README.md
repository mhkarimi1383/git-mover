# git-mover

![banner](./banner.jpg)

an script to move a git repo between two git managers (For now only for GitLab)

some times you are migrating between two gitlab or other git manager instances so you need it :)

## requirements
You should have `jq, git, curl` Ready

## How to run
1. Copy `example-env.sh` to `env.sh` & customize it.
2. 1. Run for one repo
```bash
chmod +x ./git-mover.sh
./git-mover.sh <Your Repo address>
```
2. 2. run for all repos
```bash
./move-all.sh
```

## TODO
- [x] Create another script do it for all repos (in a loop)
- [x] Variables from `env.sh` are not working (source command will solve it I think) [it should work now]
- [x] Move merge requests if it's posible
- [ ] We Are Getting Merge Requests and Merge requests curl is success but it's not creating them
- [ ] Create golang based CLI
