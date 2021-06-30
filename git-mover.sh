#!/usr/bin/env bash

# For debug (remove it if you want better output)
set -x

source ./env.sh

IFS="/"
read -ra URL <<<"$1" 
for current in "${URL[@]}";
do
FOLDER_NAME="$current"  
done

GROUP_NAME="${URL[3]}"

GROUP_ID=$(curl --header "PRIVATE-TOKEN: $PRIVATE_GITLAB_TOKEN" "https://$NEW_GITLAB_URL/api/v4/namespaces/$GROUP_NAME" | jq '.id')

echo "$GROUP_ID"

git clone "$1"
unset IFS
FULL_LOCATION=`pwd`/$FOLDER_NAME

function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

printf "\rProgress : [$(tput setaf 4)${_fill// /█}$(tput sgr 0)${_empty// /-}] ${_progress}%%"

}

# You will get an error for you defualt branch (e.g. master)
echo "$(tput setaf 4)INFO:$(tput sgr 0) pulling everything....."
_start=1
number=1
_end=$((`git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" branch -r | grep -v '\->' | wc -l`+2))
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" branch -r | grep -v '\->' |\
while read remote
do
    tput el
    tput cud1
    sleep 0.1
    tput cup 2 0
    git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" branch --track "${remote#origin/}" "$remote"
    tput cup 1 0
    ProgressBar ${number} ${_end}
    number=$((number + 1))
done
tput cup 4 0

tput el
tput cud1
sleep 0.1
tput cup 2 0
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" fetch --all
tput cup 1 0
ProgressBar ${number} ${_end}
number=$((number + 1))
tput el
tput cud1
sleep 0.1
tput cup 2 0
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" pull --all
tput cup 1 0
ProgressBar ${number} ${_end}
echo "$(tput setaf 4)INFO:$(tput sgr 0) everything pulled"

tput cup 4 0

NEW_URL=${1//$OLD_GITLAB_URL/$NEW_GITLAB_URL}

# From now on everything should be successful (if you don't want more output remove `x`')
set -ex
echo "$(tput setaf 4)INFO:$(tput sgr 0) Creating Project on new gitlab....."
NEW_PROJECT_ID=`curl --header "PRIVATE-TOKEN: $PRIVATE_GITLAB_TOKEN" "https://$NEW_GITLAB_URL/api/v4/projects?name=$FOLDER_NAME&path=$FOLDER_NAME&namespace_id=$GROUP_ID" -X POST | jq '.id'`
echo "$(tput setaf 4)INFO:$(tput sgr 0) Project created"

_end=$((`curl --header "PRIVATE-TOKEN: $OLD_PRIVATE_GITLAB_TOKEN" "https://$OLD_GITLAB_URL/api/v4/projects?search=$FOLDER_NAME" | jq '.[] | .id| wc -l`))
number=1
clear
echo "$(tput setaf 4)INFO:$(tput sgr 0) Moving Merge Requests....."
OLD_PROJECT_ID=`curl --header "PRIVATE-TOKEN: $OLD_PRIVATE_GITLAB_TOKEN" "https://$OLD_GITLAB_URL/api/v4/projects?search=$FOLDER_NAME" | jq '.[] | .id'`

PULL_REQUEST_TITLE=`curl --header "PRIVATE-TOKEN: $OLD_PRIVATE_GITLAB_TOKEN" "https://$OLD_GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests?state=opened" | jq '.[] | .title'`

TARGET_BRANCH=`curl --header "PRIVATE-TOKEN: $OLD_PRIVATE_GITLAB_TOKEN" "https://$OLD_GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests?state=opened" | jq '.[] | .target_branch'`

SOURCE_BRANCH=`curl --header "PRIVATE-TOKEN: $OLD_PRIVATE_GITLAB_TOKEN" "https://$OLD_GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests?state=opened" | jq '.[] | .source_branch'`

IFS=$'\n'

PULL_REQUEST_TITLE_LIST=($PULL_REQUEST_TITLE)
TARGET_BRANCH_LIST=($TARGET_BRANCH)
SOURCE_BRANCH_LIST=($SOURCE_BRANCH)

for (( i=0; i<${#PULL_REQUEST_TITLE_LIST[@]}; i++ ))
do
    tput el
    tput cud1
    sleep 0.1
    tput cup 2 0
    curl --headers "PRIVATE-TOKEN: $PRIVATE_GITLAB_TOKEN" -X POST "https://$NEW_GITLAB_URL/api/v4/projects/$NEW_PROJECT_ID/merge_requests?source_branch=${SOURCE_BRANCH_LIST[$i]}&target_branch=${TARGET_BRANCH_LIST[$i]}&title=${PULL_REQUEST_TITLE_LIST[$i]}"
    tput cup 1 0
    ProgressBar ${number} ${_end}
    number=$((number + 1))
done
tput cup 1 0
echo "$(tput setaf 4)INFO:$(tput sgr 0)Merge Requests Moved"
tput cup 4 0

echo "$(tput setaf 4)INFO:$(tput sgr 0) Cofiguring new remote....."
cat << EOF >> "$FULL_LOCATION"/.git/config
[remote "newRemote"]
    url = $NEW_URL
    fetch = +refs/heads/*:refs/remotes/newRemote/*
EOF
echo "$(tput setaf 4)INFO:$(tput sgr 0) New remote configured"

echo "$(tput setaf 4)INFO:$(tput sgr 0) Pushing....."
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" push -u newRemote --all
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" push -u newRemote --tags
echo "$(tput setaf 4)INFO:$(tput sgr 0) Done"

unset
exit 0
