#!/bin/bash

dkim=$(dig "${2}._domainkey.${1}" txt +nocmd +short \
| sed -e '/.*/s/.*p=\(.*\)\\[^.*]*/\1/' \
| sed 's/" "//g')

if [[ ${#dkim} > 2 ]]; then
  echo -e "$1's DKIM - \n\n$(echo $dkim | fold)"
else
  echo -e "\n$1 does not appear to have a DKIM configured!"
fi

