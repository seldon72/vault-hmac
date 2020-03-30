#!/usr/bin/env bash
set -x
# if [ -z "$1" ]; then export VLTIP=127.0.0.1; else export VLTIP=$1; fi
export REGION="us-west-1"
export VLTIP=$(aws ec2 describe-instances --region=$REGION --output text --filters "Name=tag:Role,Values=vault" --query 'Reservations[*].Instances[*].{ExtIP:PublicIpAddress}' | head -1)
export TEMPDIR="."
export PATH=$PATH:$TEMPDIR
export UNSEAL="vault operator init -recovery-shares=5 -recovery-threshold=3"
export VAULT_ADDR="http://$VLTIP:8200"

if [ ! -f "$TEMPDIR/vault.txt" ]; then
	$UNSEAL | tee $TEMPDIR/vault.txt 2>&1
fi

if [ ! -f "$TEMPDIR/vault_unseal.txt" ]; then
	cat $TEMPDIR/vault.txt | grep "^Recovery Key" | awk '{ print $4 }' 2>&1 | tee $TEMPDIR/vault_unseal.txt
fi

if [ ! -f "$TEMPDIR/vault_root_key.txt" ]; then
	cat $TEMPDIR/vault.txt | grep "^Initial Root" | awk '{ print $4 }' 2>&1 | tee $TEMPDIR/vault_root_key.txt
fi

if [ ! -f "$TEMPDIR/vault_admin_key.txt" ]; then
vault login $(cat $TEMPDIR/vault_root_key.txt)
function hcl {
cat <<- _EOF_
path "*" { capabilities = [ "read", "create", "update", "delete", "sudo", "list" ] }
_EOF_
}
export -f hcl
hcl > $TEMPDIR/admin.hcl
vault policy write admin /tmp/admin.hcl
vault token create -orphan -policy=admin | grep "^token\b" | awk '{ print $2 }' 2>&1 | tee $TEMPDIR/vault_admin_key.txt
# vault token revoke -self
fi

vault login $(cat $TEMPDIR/vault_admin_key.txt)

# index=0
# head $TEMPDIR/vault_unseal.txt | while read a; do
# 	echo vault_recovery_share_$index = $a
# 	# aws put-parameter --overwrite \
# 	# --name vault_recovery_share_$index --value $a
# 	index=$(($index+1))
# done


# aws put-parameter
