userRecipes=$(cat GF-User-recipes-to-keep.csv)

read -r -e -p "Set page start position " pagePosition
read -r -e -p "Set limit value " limit
read -r -e -p "Enter your Bearer token: " bearerToken

nextPage="init"

echo "" > putFailures.csv

patchEntry () {
  if curl -X PUT "http://localhost:8102/v1/recipes/$1" \
  -H "accept: application/ld+json"  \
  -H "Content-Type: application/ld+json"  \
  -H "Authorization: bearer $bearerToken" \
  -d "{\"meta\": {\"noIndex\":$2,\"noFollow\":$2}}" \
  --fail
  then
    echo "Success"
  else
    echo "Fail"
    echo "\"$1\"," >> putFailures.csv
  fi
}

while [[ ${nextPage} != null ]]; do
  result=$(curl -X GET "http://localhost:8102/v1/recipes?page=$pagePosition&limit=$limit" \
    -s -H "accept: application/ld+json")

  nextPage=$(echo "${result}" | jq '.["hydra:view"]' | jq '."hydra:next"')

  entriesString=$(echo "${result}" | jq '.["hydra:member"]' | jq '.[]' | jq -c '{id, userVanityRef, vanityRef}')
  entriesString="${entriesString//\"}"
  entriesString="${entriesString//\{}"
  entriesString="${entriesString//\}}"

  entriesString="${entriesString//id:}"
  entriesString="${entriesString//userVanityRef:}"
  entriesString="${entriesString//vanityRef:}"

  while read -r entry; do
    entryArray=($(echo $entry | tr "," "\n"))

    id="${entryArray[0]}"
    userVanityRef="${entryArray[1]}"
    vanityRef="${entryArray[2]}"

    match=$(echo "$userRecipes" | grep -E "${userVanityRef}/recipe/${vanityRef}" | xargs)

    if [ -n "$match" ]; then
      patchEntry "$id" "false"
    else
      patchEntry "$id" "true"
    fi

  done <<< "${entriesString}"

  pagePosition=$((pagePosition+=1))
done
