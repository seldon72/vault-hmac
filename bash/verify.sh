#!/usr/bin/env bash

TOKEN=$AWS_TOKEN
VALUE1=$(base64 <<< $1)
VALUE2=$(base64 <<< $2)
VALUE3=$(base64 <<< $3)

# grep hmac results.json > validate.txt
# mapfile -t array < validate.txt

payload="$(cat <<- EOF 
  {
      "batch_input": [
        {
          "input": "$VALUE1",
          "hmac": $(cat results.json | jq ".[0] | .hmac")
        },
        {
          "input": "$VALUE2",
          "hmac": $(cat results.json | jq ".[1] | .hmac")
        },
        {
          "input": "$VALUE3",
          "hmac": $(cat results.json | jq ".[2] | .hmac")
        }
      ]
  }
EOF
)"

curl  -H "X-Vault-Token: $TOKEN" -X POST -d "$payload" -s $VAULT_ADDR/v1/transit/verify/DOU/sha2-512 | jq ".data.batch_results"

