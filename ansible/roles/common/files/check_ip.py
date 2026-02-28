#!/usr/bin/env python3
import sys

line = sys.stdin.readline().strip()
line_parts = line.split('.')
if len(line_parts) != 4:
    sys.exit(1)
for part in line_parts:
    if not part.isdecimal():
        sys.exit(1)
    digits = int(part)
    if digits < 0 or digits > 255:
        sys.exit(1)
