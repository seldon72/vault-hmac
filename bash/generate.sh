#!/usr/bin/env bash

TOKEN=$(cat token.json)
VALUE1=$(base64 <<< $1)
VALUE2=$(base64 <<< $2)
VALUE3=$(base64 <<< $3)

payload_values()
{
  cat <<- EOF
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
}

curl -H "X-Vault-Token: $TOKEN" -X POST -d "$(payload_values)" --silent $VAULT_ADDR/v1/transit/hmac/DOU/sha2-512 | jq ".data.batch_results" -r | tee results.json
