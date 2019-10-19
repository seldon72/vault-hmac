#!/usr/bin/env bash

TOKEN=$AWS_TOKEN

curl -H "X-Vault-Token: $TOKEN" -X POST $VAULT_ADDR/v1/auth/token/revoke-self
