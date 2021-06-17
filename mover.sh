#!/usr/bin/env bash

# For debug (remove it if you want better output)
set -x

NEW_GITLAB_URL="<Your New Gitlab URL>"
PRIVATE_GITLAB_TOKEN="<Your Private Gitlab Token>"
OLD_GITLAB_URL="<Your Old Gitlab URL>"

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

# You will get an error for you defualt branch (e.g. master)
echo "$(tput setaf 4)INFO:$(tput sgr 0) pulling everything....."
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" branch -r | grep -v '\->' | while read remote; do git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" branch --track "${remote#origin/}" "$remote"; done
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" fetch --all
git --git-dir="$FULL_LOCATION/.git" --work-tree="$FULL_LOCATION" pull --all
echo "$(tput setaf 4)INFO:$(tput sgr 0) everything pulled"

NEW_URL=${1//$OLD_GITLAB_URL/$NEW_GITLAB_URL}

# From now on everything should be successful (if you don't want more output remove `x`')
set -ex
echo "$(tput setaf 4)INFO:$(tput sgr 0) Creating Project on new gitlab....."
curl --header "PRIVATE-TOKEN: $PRIVATE_GITLAB_TOKEN" "https://$NEW_GITLAB_URL/api/v4/projects?name=$FOLDER_NAME&path=$FOLDER_NAME&namespace_id=$GROUP_ID" -X POST
echo "$(tput setaf 4)INFO:$(tput sgr 0) Project created"

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
