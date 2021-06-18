#!/usr/bin/env bash

# For debug (remove it if you want better output)
set -x

./lister.sh

echo "$(tput setaf 4)INFO:$(tput sgr 0) Moving everything in a loop....."
for (( i=0; i<${#PROJECT_URL_LIST[@]}; i++ ))
do
    ./git-mover.sh "${PROJECT_URL_LIST[$i]}"
done
echo "$(tput setaf 4)INFO:$(tput sgr 0) Done. :)"

unset
exit 0