### Creating a Keyring named DOU
export ADMIN_TOKEN=<Admin Token>
export VAULT_ADDR=<Vault Server Address with port (http://127.0.0.1:8200)>

## Create Keyring
curl -H "X-Vault-Token: $ADMIN_TOKEN" -X POST -d '{ "type": "aes256-gcm96" }' $VAULT_ADDR/v1/transit/keys/DOU

## Keyring info
curl -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/transit/keys/DOU

## Rotate Key (New Version)
curl -H "X-Vault-Token: $ADMIN_TOKEN" -X POST $VAULT_ADDR/v1/transit/keys/DOU/rotate

### Setting AWS auth

## Enable auth
curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d '{"type":"aws"}' $VAULT_ADDR/v1/sys/auth/aws

## Configure credentials, create key using sample policy in https://www.vaultproject.io/docs/auth/aws.html#recommended-vault-iam-policy
export AWS_ACCESS_KEY=<AWS key>
export AWS_SECRET_KEY=<AWS secret>

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d '{"access_key":"$AWS_ACCESS_KEY", "secret_key":"$AWS_SECRET_KEY"}' $VAULT_ADDR/v1/auth/aws/config/client 

## Create Policy DOU-policy
cat << EOF > DOU-policy.hcl
{
  "policy": "# Verify Hash\npath \"transit/verify/DOU/*\"\n{\n  capabilities = [\"create\", \"update\"]\n}\n\n# HMAC Hash\npath \"transit/hmac/DOU/*\"\n{\n  capabilities = [\"create\", \"update\"]\n}"
}
EOF

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d @DOU-policy.hcl $VAULT_ADDR/v1/sys/policy/DOU-policy

## List policies
curl -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/sys/policy

## Crete Role - bind to AWS account, EC2 instance id or AMI id
AWS_ACCOUNT=<AWS account>

cat << EOF > payload.json
{
    "bound_account_id":"$AWS_ACCOUNT",
    "auth_type":"ec2",
    "policies":"DOU-policy"
}
EOF

curl  -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d @payload.json $VAULT_ADDR/v1/auth/aws/role/DOU-role
  
## Delete Role
curl -X DELETE -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/auth/aws/role/DOU-role

## List Role
curl -H "X-Vault-Token: $ADMIN_TOKEN" $VAULT_ADDR/v1/auth/aws/role/DOU-role

