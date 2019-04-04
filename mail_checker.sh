#!/bin/bash

# Arrays for holding all the repetitive data

declare -a domains
declare -A addresses

# Could make an associative array on a per-domain basis that holds a bunch of strings 
# each representing some feature of the domain
# e.g. - domain_info[$DOMAIN]="admin|info|contact, total storage , perms check , DNS info/checks"
# Can store addresses in there too! This way the value can be pulled from the array to do operations

# Checks $HOME/mail for domains and adds them to the domains array

for DOMAIN in $(find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc)\w+\.\w+)|\w+$)' | cut -d'/' -f5); do
  domains+=($DOMAIN)
done

# Iterates through domains array and assigns a list of addresses
# that pass certain checks to their domain in the addresses array

for DOMAIN in "${domains[@]}"; do
  for ADDRESS_SHADOW in $(awk -F':' '{print $1}' $HOME/etc/$DOMAIN/shadow); do
    for ADDRESS_PASSWD in $(awk -F':' '{print $1}' $HOME/etc/$DOMAIN/shadow); do
      [[ $ADDRESS_SHADOW == $ADDRESS_PASSWD ]] && \
      [[ -e $HOME/mail/$ADDRESS_SHADOW ]] && \ 
      addresses[$DOMAIN]="$ADDRESS_PASSWD"
    done
  done
done

printf "\n%b\n" "If an address does not appear in this list check $HOME/etc/<domain>/{shadow,passwd} for the missing entries, $HOME/mail/<domain> for content, and mailperm.\n"
for i in "${!addresses[@]}"; do
  printf "%b" "${addresses[$i]}""@""$i\n"
done
printf "%b" "\nDomain mail size breakdown:\n"

# TODO Check for orphaned entries in shadow/passwd/mail

# TODO Display size (breakdown and total), quotas, mail count (per box and total)

domain_size(){
	du -sh $HOME/mail/$DOMAIN;
}

address_size(){
	du -sh $HOME/mail/$DOMAIN/$ADDRESS;
}

for DOMAIN in "${domains[@]}"; do
  printf "\n%s" "$(domain_size)"
done

printf "%b" "\n"

for ADDRESS in "${addresses[@]}"; do
  printf "\n%s" "$(address_size)"
done

printf "\n%b" "\n"
# Total size of each domain
# Per box breakdown


# TODO Do MX check (IP , remote/local)

# TODO Check for forwarders, autoresponders, filters

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms
