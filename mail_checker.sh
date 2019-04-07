#!/bin/bash

## Arrays ##

declare -A domain_info

## Functions go here ##

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

# Prints DNS info with trailing "." trimmed
# get_mx $domain $record

get_mx(){
  dig +nocmd $1 $2 +multiline +noall +answer | sed -r 's/\.(\s|$)/ /g'
}

# TODO make this output nicer ?
# Grabs and prints sizes

get_size(){
        du -sh $HOME/mail/$1/$2;
}

# Runs some checks on addresses in shadow and passwd for a given domain
# hash_checker domain (passwd|shadow) (passwd|shadow)

hash_checker(){
  for address in $(awk -F':' '{print $1}' $HOME/etc/$1/$2); do
    if grep -q $address $HOME/etc/$domain/$3 && \
    [[ -e $HOME/mail/$1/$address ]]; then
      continue
    else
      echo -e "\n$address@$domain may have issues. Check that"\
      "address exists in $HOME/mail/${1}, has entries in"\
      "$HOME/etc/$1/{shadow,passwd}, and that permissions are correct."
    fi
  done
}

# Iterates through output of get_addresses and pairs address names with 
# their domain in the domain_info array

for i in $(get_addresses); do
  address="$(echo $i | cut -d'@' -f1)"
  domain="$( echo $i | cut -d'@' -f2)"
  domain_info["$domain"]+="$address "
done

for i in "${!domain_info[@]}"; do
  echo -e "\n${i}" "contains the following addresses:\n\n${domain_info[$i]}"
done

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

# Total size of each domain

echo -e "\nTotal mail size by domain:\n"

for domain in "${!domain_info[@]}"; do
  echo "$(get_size $domain)"
done

# TODO quotas, mail count for each box, inbox/sent/trash DU breakdown
# TODO Check for forwarders, autoresponders, filters

echo -e "\nTotal mail size by address:\n"

for domains in "${!domain_info[@]}"; do
  for domain in $domains; do
    for addresses in "${domain_info[$domain]}"; do
      for address in $addresses; do
        echo "${address}@${domain} - $(get_size $domain $address)"
      done
    done
  done
done


# TODO Do MX check (IP , remote/local, SPF/DKIM)

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms

echo
