#!/usr/bin/env python3

import requests
import os
import urllib

vault_addr = os.getenv('VAULT_ADDR')
url = urllib.parse.urljoin(vault_addr, 'v1/auth/aws/login')
pkcs = requests.get('http://169.254.169.254/latest/dynamic/instance-identity/pkcs7')

payload={}
payload['pkcs7'] = pkcs.text.replace('\n', '')
payload['nonce'] = 'HMAC'
payload['role'] = 'DOU-role'

t = requests.post(url, json=payload)

print(t.json()['auth']['client_token'])
