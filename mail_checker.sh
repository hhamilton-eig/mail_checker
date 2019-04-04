#!/bin/bash

# TODO Arrange (several?) array(s) to store all the domain names and info about them

declare -a domains
declare -A addresses

# TODO Write some regex that captures domain names in $HOME/mail

# Run find from $HOME so output looks like $HOME/etc/<stuff>
# find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc)\w+\.\w+)|\w+$)' | cut -d'/' -f5

# Actually try /var/cpanel/users/$user and /var/cpanel/userdata/$user
# awk -F'DNS[0-9]?=' ' NF > 1 {print $2}' /var/cpanel/users/$(whoam i)

# TODO Display all addresses for each domain found in $HOME/mail by checking shadow + passwd


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

for i in "${!addresses[@]}"; do
  printf "%s\t%s\n" "${addresses[$i]}""@""$i"
done

# TODO Check for orphaned entries in shadow/passwd/mail

# TODO Display size (breakdown and total), quotas, mail count (per box and total)

# TODO Do MX check (IP , remote/local)

# TODO Check for forwarders, autoresponders, filters

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms
