#!/bin/bash

# Arrays for holding all the repetitive data

declare -a domains
declare -A addresses

# Could make an associative array on a per-domain basis that holds a bunch of strings 
# each representing some feature of the domain
# e.g. - domain_info[$DOMAIN]="admin|info|contact, total storage , perms check , DNS info/checks"
# Can store addresses in there too! This way the value can be pulled from the array to do operations

# Checks $HOME/mail for domains and adds them to the domains array

for DOMAIN in $(find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc)\w+\.\w+)|\w+$)' \
| cut -d'/' -f5); do
  domains+=("$DOMAIN")
done

# TODO Do MX check (IP , remote/local, SPF/DKIM)

# Iterates through domains array and assigns a list of addresses
# that pass certain checks to their domain in the addresses array

for DOMAIN in "${domains[@]}"; do
  for ADDRESS_SHADOW in $(awk -F':' '{print $1}' $HOME/etc/$DOMAIN/shadow); do
    for ADDRESS_PASSWD in $(awk -F':' '{print $1}' $HOME/etc/$DOMAIN/shadow); do
      [[ $ADDRESS_SHADOW == $ADDRESS_PASSWD ]] && \
      [[ -e $HOME/mail/$DOMAIN/$ADDRESS_SHADOW ]] && \
      addresses[$DOMAIN]="$ADDRESS_PASSWD"
    done
  done
done

echo -e "\nIf an address does not appear in this list, check" \
" $HOME/etc/<domain>/{shadow,passwd} for the missing entries, $HOME/mail/<domain> for content," \
"and potentially run mailperm.\n"
for i in "${!addresses[@]}"; do
  echo -e "${addresses[$i]}""@""$i"
done

# Checks for orphaned entries in $HOME/etc/$DOMAIN/{shadow,passwd}
# TODO add uapi loop that recreates addresses if user says "yes" for each domain

for DOMAIN in "${domains[@]}"; do
  if [[ $(wc -l $HOME/etc/$DOMAIN/shadow) == $(wc -l $HOME/etc/$DOMAIN/passwd) ]]; then
    echo -e "\nLength of shadow and passwd files match."
  else
    echo -e "\nThe length of the shadow and passwd files for $DOMAIN do not match." \
" Would you like to recreate the addresses in the longer of the two files?" \
" Warning! This will reset passwords for all email addresses under this domain," \
" so only do it if you are sure."
  fi
done

# Functions for grabbing sizes

domain_size(){
	du -sh $HOME/mail/$DOMAIN;
}

address_size(){
	du -sh $HOME/mail/$DOMAIN/$ADDRESS;
}

# Total size of each domain

echo -e "\nTotal mail size by domain:\n"

for DOMAIN in "${domains[@]}"; do
  echo "$(domain_size)"
done

# TODO quotas, mail count for each box, inbox/sent/trash DU breakdown
# TODO Check for forwarders, autoresponders, filters

echo -e "\nTotal mail size by address:\n"

for DOMAIN in "${domains[@]}"; do
  for ADDRESS in \
  $(find $HOME/mail/$DOMAIN -maxdepth 1 -regextype posix-egrep  -regex '(\/\w+){4}\.\w+\/.*' | cut -d'/' -f6); do
  address_size
  done
  echo
done

# Can't do before addresses array gets refactored to include all addresses
#for ADDRESS in "${addresses[@]}"; do
#  echo "$(address_size)"
#done

echo

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms
