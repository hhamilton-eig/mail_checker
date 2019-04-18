#!/bin/bash

# Raw DKIM key value
dkim=$(dig "${2}._domainkey.${1}" txt +nocmd +short \
| awk -F';|=|"|\\\\' '{print $9$11}')

# Formatted key for openssl
pretty_dkim="-----BEGIN PUBLIC KEY-----\n\
$dkim\n\
-----END PUBLIC KEY-----"

# Checks if dkim variable has length greater than 2 chars to weed out ""
if [[ ${#dkim} > 2 ]]; then
  echo -e "\n${1}'s DKIM -\n"
  echo -e $pretty_dkim | fold -w 64 | openssl rsa -noout -text -pubin | head -1
  echo 
  echo -e $pretty_dkim | fold -w 64
else
  echo -e "\n$1 does not appear to have a DKIM configured!"
fi
echo

