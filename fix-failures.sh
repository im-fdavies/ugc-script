#!/bin/bash

environmentUrl=https://ugr-api-staging.headless-sandbox.imdserve.com/v1/recipes
#environmentUrl=http://localhost:8102/v1/recipes

read -r -e -p "Enter your Bearer token: " bearerToken
echo "" > putFailures2.csv

patchEntry () {
  if curl -X PUT "$environmentUrl/$1" \
  -H "accept: application/ld+json"  \
  -H "Content-Type: application/ld+json"  \
  -H "Authorization: bearer $bearerToken" \
  -d "{\"meta\": {\"noIndex\":$2,\"noFollow\":$2}}" \
  --fail
  then
    echo "Success"
  else
    echo "Fail"
    echo "$1, $2," >> putFailures2.csv
  fi
}

  INPUT=putFailures.csv
  OLDIFS=$IFS
  IFS=','
  [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
  while read id metaValue
  do
    echo "id : $id"
    echo "metaValue : $metaValue"

    patchEntry "$id" "$metaValue"
  done < $INPUT
  IFS=$OLDIFS
