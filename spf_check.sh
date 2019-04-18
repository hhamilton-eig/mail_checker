#!/bin/bash

# Stores SPF record

spf="$(dig $1 txt | awk -F'"' '/spf/{print $2}')"

# Checks if SPF is greater than 0 chars

if [[ $spf | head -c1 | wc -c) -ne 0 ]]; then
  echo -e "$1's SPF - \n$spf"
else
  echo -e "\n$1 does not appear to have an SPF configured!"
fi

