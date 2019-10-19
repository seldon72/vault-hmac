#!/usr/bin/env python3

import requests
import os
import urllib

vault_addr = os.getenv('VAULT_ADDR')
token = os.getenv('AWS_TOKEN')
url = urllib.parse.urljoin(vault_addr, 'v1/auth/token/revoke-self')

d = requests.post(url, headers={'X-Vault-Token': token})

if d:
    print('Success')
else:
    print('Error')
