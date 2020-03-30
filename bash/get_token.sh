#!/usr/bin/env bash
set -x
PKCS=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')

payload_token()
{
  cat <<- EOF
  {
      "role":"DOU-role",
      "pkcs7":"$PKCS",
      "nonce":"HMAC"
  }
EOF
}

curl -s -X POST -d "$(payload_token)" $VAULT_ADDR/v1/auth/aws/login | jq ".auth.client_token" -r | tee token.json
