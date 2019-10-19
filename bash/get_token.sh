#!/usr/bin/env bash

PKCS=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')

cat << EOF > payload.json
{
    "role":"DOU-role",
    "pkcs7":"$PKCS",
    "nonce":"HMAC"
}
EOF

curl -s -X POST -d @payload.json $VAULT_ADDR/v1/auth/aws/login | jq "." | tee token.json

