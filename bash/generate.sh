#!/usr/bin/env bash

TOKEN=$AWS_TOKEN
VALUE1=$(base64 <<< $1)
VALUE2=$(base64 <<< $2)
VALUE3=$(base64 <<< $3)

payload="$(cat <<- EOF 
  {
      "batch_input": [
        {
          "input": "$VALUE1"
        },
        {
          "input": "$VALUE2"
        },
        {
          "input": "$VALUE3"
        }
      ]
  }
EOF
)"

curl  -H "X-Vault-Token: $TOKEN" -X POST -d "$payload" --silent $VAULT_ADDR/v1/transit/hmac/DOU/sha2-512 | jq ".data.batch_results" | tee results.json

