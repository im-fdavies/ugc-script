#!/bin/bash

userRecipes=$(cat GF-User-recipes-to-keep-preprod.csv)
environmentUrl=https://ugr-api-preproduction.headless-preproduction.imdserve.com/v1/recipes
#environmentUrl=https://ugr-api-staging.headless-sandbox.imdserve.com/v1/recipes
#environmentUrl=http://localhost:8102/v1/recipes

# Set options
while getopts 'e:' flag
do
  case ${flag} in
      e) environmentUrl=${OPTARG};
         ;;
      *) printf "Usage: [ -e 'environmentUrl' ]";
         exit 1;
         ;;
  esac
done

read -r -e -p "Set page start position " pagePosition
read -r -e -p "Set limit value " limit
read -r -e -p "Enter your Bearer token: " bearerToken

nextPage="init"

echo "" > putFailures.csv

patchEntry () {
  if curl -X PUT "$environmentUrl/$1" \
  -H "Accept: application/json"  \
  -H "Content-Type: application/ld+json"  \
  -H "Authorization: Bearer $bearerToken" \
  -d "{\"meta\": {\"noIndex\": $2, \"noFollow\": $2}}" \
  --fail
  then
    echo "Success"
  else
    echo "Fail"
    echo "$1, $2" >> putFailures.csv
  fi
  sleep 10s;
}

while [[ ${nextPage} != null ]]; do
  result=$(curl -X GET "$environmentUrl?page=$pagePosition&limit=$limit" \
    -s -H "accept: application/ld+json")

  nextPage=$(echo "${result}" | jq '.["hydra:view"]' | jq '."hydra:next"')
  echo "$nextPage"

  entriesString=$(echo "${result}" | jq '.["hydra:member"]' | jq '.[]' | jq -c '{id, userVanityRef, vanityRef}')
  entriesString="${entriesString//\"}"
  entriesString="${entriesString//\{}"
  entriesString="${entriesString//\}}"

  entriesString="${entriesString//id:}"
  entriesString="${entriesString//userVanityRef:}"
  entriesString="${entriesString//vanityRef:}"

  while read -r entry; do
    entryArray=($(echo "$entry" | tr "," "\n"))

    id="${entryArray[0]}"
    userVanityRef="${entryArray[1]}"
    vanityRef="${entryArray[2]}"

    if [ "${id}" = "" ]; then
        exit 1
    fi

    match=$(echo "$userRecipes" | grep -E "${userVanityRef}/recipe/${vanityRef}" | xargs)

    if [ -n "$match" ]; then
      patchEntry "$id" "false"
    else
      patchEntry "$id" "true"
    fi

  done <<< "${entriesString}"

  pagePosition=$((pagePosition+=1))
done
