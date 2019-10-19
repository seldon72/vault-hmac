#!/usr/bin/env bash

TOKEN=$AWS_TOKEN
VALUE1=$(base64 <<< $1)
VALUE2=$(base64 <<< $2)
VALUE3=$(base64 <<< $3)

grep hmac results.json > validate.txt
mapfile -t array < validate.txt

cat << EOF > payload.json
{
    "batch_input": [
      {
        "input": "$VALUE1",
        ${array[0]}
      },
      {
        "input": "$VALUE2",
        ${array[1]}
      },
      {
        "input": "$VALUE3",
        ${array[2]}
      }
    ]
}
EOF

curl  -H "X-Vault-Token: $TOKEN" -X POST -d @payload.json -s $VAULT_ADDR/v1/transit/verify/DOU/sha2-512 | jq ".data.batch_results"
