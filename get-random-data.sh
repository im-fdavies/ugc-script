#!/bin/bash

  result=$(curl -X GET "https://ugr-api-preproduction.headless-preproduction.imdserve.com/v1/recipes?page=7&limit=30" \
    -s -H "accept: application/ld+json")

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
  echo "$savedEntry" >> newEntriesPreProd.csv

done <<< "${entriesString}"
