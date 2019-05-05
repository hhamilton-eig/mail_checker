#!/bin/bash

# Iterates through domains and performs shadow/passwd file checks

for domain in "${!domain_info[@]}"; do
  if [[ -e $HOME/etc/$domain/passwd ]] && \
  [[ -e $HOME/etc/$domain/shadow ]]; then
    hash_checker $domain shadow passwd
    hash_checker $domain passwd shadow
  else
    echo -e "\nThere is something wrong with the shadow/passwd files for ${domain}." \
    "Check that they exist and that permissions are correct.\n"
  fi
done

# TODO add uapi loop that recreates addresses if user says "yes" for each domain
