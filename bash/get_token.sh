#!/usr/bin/env bash
set -x
# PKCS=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')
IDENTITY=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/rsa2048 | tr -d '\n')
SIGNATURE=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/signature | tr -d '\n')

payload()
{
  cat <<- EOF
  {
      "role":"DOU-role",
      "identity":"$IDENTITY",
      "signature":"$SIGNATURE",
      "nonce":"HMAC"
  }
EOF
}

curl -s -X POST -d "$(payload)" $VAULT_ADDR/v1/auth/aws/login | jq "." | tee token.json
