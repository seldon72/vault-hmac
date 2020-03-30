#!/usr/bin/env bash
set -x
export TEMPDIR="../"
export PATH=$PATH:$TEMPDIR
export REGION="us-west-1"
export AWSPOLICY=""
export AWS_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SECRET_KEY=$AWS_ACCESS_KEY_ID

export VLTIP=$(aws ec2 describe-instances --region=$REGION --output text --filters "Name=tag:Role,Values=vault" --query 'Reservations[*].Instances[*].{ExtIP:PublicIpAddress}' | head -1)
export VAULT_ADDR="http://$VLTIP:8200"

export ADMIN_TOKEN=$(cat $TEMPDIR/vault_admin_key.txt)
export AWS_ACCOUNT="subnet-0324f9a22b3196013,subnet-01a2c149a5bf1bdc8,subnet-0dd0ed6d0219a3d3b"
# export AWS_ACCOUNT=$(aws ec2 describe-instances --region=$REGION --output text --filters "Name=tag:Role,Values=vault" --query 'Reservations[*].Instances[*].{Instance:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,ExtIP:PublicIpAddress}' | awk -vORS=, '{ print $2 }' | sed 's/,$/\n/')
# export AWS_ACCOUNT="237889007525"

## Enable Transit Engine
vault secrets list | grep transit
if [ $? -ne 0 ]; then
  vault secrets enable transit
fi

# Create Key Ring
curl -H "X-Vault-Token: $ADMIN_TOKEN" -X POST -d '{ "type": "aes256-gcm96" }' $VAULT_ADDR/v1/transit/keys/DOU

#enable AWS Auth
curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d '{"type":"aws"}' $VAULT_ADDR/v1/sys/auth/aws

# Setup Credentials
curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d "{"access_key":"$AWS_ACCESS_KEY_ID", "secret_key":"$AWS_SECRET_ACCESS_KEY"}" $VAULT_ADDR/v1/auth/aws/config/client

# Create Policy
policy_data()
{
  cat << EOF
{
  "policy": "# Verify Hash\npath \"transit/verify/DOU/*\"\n{\n  capabilities = [\"create\", \"update\"]\n}\n\n# HMAC Hash\npath \"transit/hmac/DOU/*\"\n{\n  capabilities = [\"create\", \"update\"]\n}"
}
EOF
}

# Reference https://www.vaultproject.io/api-docs/auth/aws/ for the bound login options
payload_data()
{
  cat << EOF
{
    "bound_subnet_id":"$AWS_ACCOUNT",
    "auth_type":"ec2",
    "policies":"DOU-policy"
}
EOF
}

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d "$(policy_data)" $VAULT_ADDR/v1/sys/policy/DOU-policy

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d "$(payload_data)" $VAULT_ADDR/v1/auth/aws/role/DOU-role


## Useful commands
## Keyring info
# curl -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/transit/keys/DOU

## Rotate Key (New Version)
# curl -H "X-Vault-Token: $ADMIN_TOKEN" -X POST $VAULT_ADDR/v1/transit/keys/DOU/rotate

## List policies
# curl -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/sys/policy
# curl -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/auth/aws/role/DOU-role
