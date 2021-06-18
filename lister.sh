#!/usr/bin/env bash

# everything should be successful (if you don't want more output remove `x`')
set -xe

./env.sh

echo "$(tput setaf 4)INFO:$(tput sgr 0) Getting the list of projects that you are a member of them....."
PROJECT_URL_LIST=$(curl -s --header "PRIVATE-TOKEN: $OLD_PRIVATE_GITLAB_TOKEN" "https://$OLD_GITLAB_URL/api/v4/projects?membership=true" | jq '.[] | .http_url_to_repo')
IFS=$'\n'
PROJECT_URL_LIST=($PROJECT_URL_LIST)
echo "$(tput setaf 4)INFO:$(tput sgr 0) List saved in PROJECT_URL_LIST variable"

unset IFS