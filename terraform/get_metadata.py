#!/usr/bin/env python3
from collections import defaultdict
from re import search

template = ''
users = ''

with open('metadata_template.yml', encoding='utf-8') as f:
    template = f.read()

user_keys = defaultdict(list)
with open('ssh_users', encoding='utf-8') as f:
    for user in f.readlines():
        if user.isspace():
            continue
        username, ssh_key = user.split(':', 2)
        user_keys[username].append(ssh_key[:-1])

template_parts = template.partition('\nusers:\n')
start_part = template_parts[0] + template_parts[1]
user_part = template_parts[2]
print(start_part, end='')

key_ident = search(r'\n(.*?)\{ssh_key\}', user_part).group(1)
for user, public_keys in user_keys.items():
    key_text = f'\n{key_ident}'.join(public_keys)
    print(user_part.format(username=user, ssh_key=key_text), end='')
