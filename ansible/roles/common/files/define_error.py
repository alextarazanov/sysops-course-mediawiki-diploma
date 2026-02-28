#!/usr/bin/env python3
import sys

input_line = sys.stdin.readline().strip()
first_char = input_line[:1]
if first_char == '5' or first_char == '0':
    print(1)
else:
    print(0)

