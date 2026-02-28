#!/usr/bin/env bash
if ! $(echo "$1" | ./check_ip.py) ; then
  echo 1
  exit 1
fi
if [ -n "$1" ]; then
  curl -s -m 5 -o /dev/null -w "%{http_code}\n" "$1" | ./define_error.py
else
  echo 1
  exit 1
fi
