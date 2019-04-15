#!/bin/bash

if [[ $(dig $1 txt | awk -F'"' '/spf/{print $2}' | head -c1 | wc -c) -ne 0 ]]; then
  echo -e "$1's SPF - \n$(dig $1 txt | awk -F'"' '/spf/{print $2}')"
else
  echo -e "\n$1 does not appear to have an SPF configured!"
fi

