#!/usr/bin/env python3

import requests
import os
import urllib
import sys
import json
import base64

vault_addr = os.getenv('VAULT_ADDR')
token = os.getenv('AWS_TOKEN')
url = urllib.parse.urljoin(vault_addr, 'v1/transit/verify/DOU/sha2-512')

with open('results.json') as json_file:
    data = json.load(json_file)

payload = []
for i in range(0,3):
    payload.append({'input':base64.b64encode(sys.argv[i+1].encode('utf-8')).decode('utf-8')})
    payload[i].update(data[i])

verify = requests.post(url, headers={'X-Vault-Token': token}, json={'batch_input': payload})

print(json.dumps(verify.json()['data']['batch_results'], indent=4, sort_keys=True))
