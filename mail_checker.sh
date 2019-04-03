#!/bin/bash

# TODO Write some regex that captures domain names in $HOME/mail

# Run find from etc so output looks like ./<stuff>
# cd $HOME/etc && find -regextype posix-egrep -regex '\.\/\w+\.(((?!rc)\w+\.\w+)|\w+$)' | cut -d'/' -f2

# Run find from $HOME so output looks like $HOME/etc/<stuff>
# hhamilt1@findmypolitician.org [~]# find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc)\w+\.\w+)|\w+$)' | cut -d'/' -f5

#Actually try /var/cpanel/users/$user and /var/cpanel/userdata/$user

# TODO Display all addresses for each domain found in $HOME/mail by checking shadow + passwd

# TODO Check for orphaned entries in shadow/passwd/mail

# TODO Display size (breakdown and total), quotas, mail count (per box and total)

# TODO Do MX check (IP , remote/local)

# TODO Check for forwarders, autoresponders, filters

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms
