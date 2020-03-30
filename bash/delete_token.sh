#!/usr/bin/env bash

TOKEN=$(cat token.json)

curl -H "X-Vault-Token: $TOKEN" -X POST $VAULT_ADDR/v1/auth/token/revoke-self

rm results.json token.json
