# Vault HMAC hashing project

HMAC encoding and verification POC using HashiCorp Vault

Requires a HashiCorp Valut server 

## Set Up (One Time) - Scripts in *config*

### Creating a Keyring named DOU
An admin token and the Vault server address are needed
```bash
export ADMIN_TOKEN=<Admin Token>
export VAULT_ADDR=<Vault Server Address with port (http://127.0.0.1:8200)>
```

#### Create Keyring
```bash
curl -H "X-Vault-Token: $ADMIN_TOKEN" -X POST -d '{ "type": "aes256-gcm96" }' $VAULT_ADDR/v1/transit/keys/DOU
```

### Setting AWS auth

#### Enable auth
```bash
curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d '{"type":"aws"}' $VAULT_ADDR/v1/sys/auth/aws
```

#### Configure credentials, create AWS key using sample policy [here](https://www.vaultproject.io/docs/auth/aws.html#recommended-vault-iam-policy)
```bash
export AWS_ACCESS_KEY=<AWS key>
export AWS_SECRET_KEY=<AWS secret>

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d '{"access_key":"$AWS_ACCESS_KEY", "secret_key":"$AWS_SECRET_KEY"}' $VAULT_ADDR/v1/auth/aws/config/client 
```

#### Create Policy DOU-policy
```bash
cat << EOF > DOU-policy.hcl
{
  "policy": "# Verify Hash\npath \"transit/verify/DOU/*\"\n{\n  capabilities = [\"create\", \"update\"]\n}\n\n# HMAC Hash\npath \"transit/hmac/DOU/*\"\n{\n  capabilities = [\"create\", \"update\"]\n}"
}
EOF

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d @DOU-policy.hcl $VAULT_ADDR/v1/sys/policy/DOU-policy
```
#### Crete Role - bind to AWS account, EC2 instance id or AMI id
```bash
AWS_ACCOUNT=<AWS account>

cat << EOF > payload.json
{
    "bound_account_id":"$AWS_ACCOUNT",
    "auth_type":"ec2",
    "policies":"DOU-policy"
}
EOF

curl -X POST -H "X-Vault-Token: $ADMIN_TOKEN" -d @payload.json $VAULT_ADDR/v1/auth/aws/role/DOU-role
```

## Generate and Verify HMAC hash on EC2 instance
### BASH

#### Set Vault Address variable
```bash
export VAULT_ADDR=<Vault Server Address with port (http://127.0.0.1:8200)>
```

#### Get login token using AWS auth 
```bash
export AWS_TOKEN=$(./get_token.sh | jq -r ".auth.client_token")
```

#### Encode User, Password and PIN (3 parameters expected)
```bash
./generate.sh $USER $PASSWORD $PIN
```

#### Verify data comparing with HMAC hash (3 parameters expected)
```bash
./verify.sh $USER $PASSWORD $PIN
```
  
#### Delete token 
```bash
./delete_token.sh
```  

### Python

#### Set Vault Address variable
```bash
export VAULT_ADDR=<Vault Server Address with port (http://127.0.0.1:8200)>
```

#### Get login token using AWS auth 
```bash
export AWS_TOKEN=$(./get_token.py)
```

#### Encode User, Password and PIN (3 parameters expected)
```bash
./generate.py $USER $PASSWORD $PIN
```

#### Verify data comparing with HMAC hash (3 parameters expected)
```bash
./verify.py $USER $PASSWORD $PIN
```
  
#### Delete token 
```bash
./delete_token.py
```  