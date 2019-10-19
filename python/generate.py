#!/usr/bin/env python3

import requests
import os
import urllib
import sys
import json
import base64

vault_addr = os.getenv('VAULT_ADDR')
token = os.getenv('AWS_TOKEN')
url = urllib.parse.urljoin(vault_addr, 'v1/transit/hmac/DOU/sha2-512')

payload = []
for value in sys.argv[1:]:
    payload.append({'input':base64.b64encode(value.encode('utf-8')).decode('utf-8')})

generate = requests.post(url, headers={'X-Vault-Token': token}, json={'batch_input': payload})

with open('results.json', 'w') as hmac:
    json.dump(generate.json()['data']['batch_results'], hmac)

print(json.dumps(generate.json()['data']['batch_results'], indent=4, sort_keys=True))
