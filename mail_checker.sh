#!/bin/bash

## Arrays ##

declare -A domain_info

## Functions ##

# Prints a list of domains present in $HOME/mail

get_domains(){
  find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc )\w+\.\w+)|\w+$)' \
  | cut -d'/' -f5
}

# Prints a list of addresses present in $HOME/mail

get_addresses(){
  find $HOME/mail/*/ -maxdepth 1 -regextype posix-egrep  -regex '(\/\w+){4}\.\w+\/\S+' \
  | awk 'BEGIN {FS="/"; OFS="@"} {print $6, $5}'
}

# TODO make this output nicer?
# Grabs and prints sizes

get_size(){
        du -sh $HOME/mail/$1/$2;
}

# Iterates through output of get_addresses and pairs address names with their domain in the info array

for i in $(get_addresses); do
  address=$( echo $i | cut -d'@' -f1)
  domain=$( echo $i | cut -d'@' -f2)
  domain_info["$domain"]+="$address|"
done

# Echo test of array contents
#for i in "${!domain_info[@]}"; do
#  echo -e "\n${i}" "contains the following addresses" ${domain_info[$i]}
#done

# Iterates through domains and performs shadow/passwd file checks

for domain in "${!domain_info[@]}"; do
  if [[ -e $HOME/etc/$domain/passwd ]] && \
  [[ -e $HOME/etc/$domain/shadow ]] && \
  [[ $(wc -l $HOME/etc/$domain/shadow) != $(wc -l $HOME/etc/$domain/passwd) ]] ; then
    if [[ $(wc -l $HOME/etc/$domain/shadow) > $(wc -l $HOME/etc/$domain/passwd) ]] ; then
      for address in $(awk -F':' '{print $1}' $HOME/etc/$domain/shadow); do
        if grep -q $address $HOME/etc/$domain/passwd; then
          continue
        else 
          echo -e "\n$address@$domain may have issues"
        fi
      done
    else
      for address in $(awk -F':' '{print $1}' $HOME/etc/$domain/passwd); do
        if grep -q $address $HOME/etc/$domain/shadow; then
          continue
        else
          echo -e "\n$address@$domain may have issues"
        fi
      done
    fi
  fi
done

# TODO add uapi loop that recreates addresses if user says "yes" for each domain

# TODO make output prettier
# Total size of each domain

echo -e "\nTotal mail size by domain:\n"

for domain in "${!domain_info[@]}"; do
  echo "$(get_size $domain)"
done

# TODO mail count for each box, inbox/sent/trash DU breakdown
# Size breakdown of addresses

echo -e "\nTotal mail size by address:\n"

for address in "${domain_info[@]}"; do
  echo $(get_size $address)
done

# TODO Check for forwarders, autoresponders, filters, quotas

# TODO Do MX check (IP , remote/local, SPF/DKIM)

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms

echo
