mailchk

cPanel mail checker CLI by Heston Hamilton

Installation instructions:
```
git clone https://github.com/TheGingeraffe/mail_checker

./mail_checker/mailchk
```
Usage:
```
mailchk $command [domain(s)]

Commands:
   
\* Help

-(d)ns          NS/MX/SPF/DKIM/DMARC check

-(b)reakdown    Storage breakdown

-(i)ntegrity    Shadow/passwd/maildir checks
```
Each command option can accept a space-delimited list of domains. The command will run for all domains on the account if given no optional arguments.
