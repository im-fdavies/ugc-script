#!/bin/bash

  result=$(curl -X GET "https://ugr-api-staging.headless-sandbox.imdserve.com/v1/recipes?page=13&limit=100" \
    -s -H "accept: application/ld+json")

  echo "" > newEntries.csv

  entriesString=$(echo "${result}" | jq '.["hydra:member"]' | jq '.[]' | jq -c '{userVanityRef, vanityRef}')
  entriesString="${entriesString//\"}"
  entriesString="${entriesString//\{}"
  entriesString="${entriesString//\}}"

  entriesString="${entriesString//userVanityRef:}"
  entriesString="${entriesString//vanityRef:}"

  while read -r entry; do
  entryArray=($(echo "$entry" | tr "," "\n"))

  userVanityRef="${entryArray[0]}"
  vanityRef="${entryArray[1]}"

  savedEntry="https://www.bbcgoodfood.com/user/${userVanityRef}/recipe/${vanityRef}"

  echo $savedEntry
  echo "$savedEntry" >> newEntries.csv

done <<< "${entriesString}"
