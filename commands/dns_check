#!/bin/bash

# TODO Find authoritative NS from WHOIS, do a cURL to workaround broke whois command (segfault on shared)
# Checks and prints NS + MX info for domains in array
for domain in "${!domain_info[@]}"; do
  echo -e "DNS checks for ${domain}:\n"
  get_dns $domain ns
  echo
  get_dns $domain mx
  echo
done

# Stores SPF record

spf="$(dig $1 txt | awk -F'"' '/spf/{print $2}')"

# Checks if SPF is greater than 0 chars

if [[ $($spf | head -c1 | wc -c) -ne 0 ]]; then
  echo -e "$1's SPF - \n$spf"
else
  echo -e "\n$1 does not appear to have an SPF configured!"
fi

# Does not cover all DKIMS, fix for default._domainkey.recruiterhq.ca.
# {print $6} with current awk

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

# Ask for DKIM selector when run, or just assume default?
# Possible selectors: default, google, dkim
# Search through mail headers for dkim?

# TODO DMARC


