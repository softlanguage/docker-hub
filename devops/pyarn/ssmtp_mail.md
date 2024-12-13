
- test ssmtp by mail or sendmail
> job must finish in 5minutes

```sh
(cmd111_will_error || echo "\n>>errord at $(date)\n") 2>&1 | tee -a /tmp/cron-test02.log
(date || echo ">>errord at $(date)") 2>&1 | tee -a /tmp/cron-test03.log

# check mysql-mdm-on-vpn
if ! sh -ec 'mysqladmin ping -h mdm-mysql.dev -uReadonly -pPass'; then
echo "send mail to notice admin"
echo 'mysql throuth VPN not available' | mail -s '[Failed] mysql.mdm check failed' bug.fyi@mail.local
fi

# run command on container
if ! docker exec -i mysql-m25.prd bash -e <<<"echo test;date"; then
echo "prd-mysql-m25 backup failed"
printf "Subject: [Failed] yyy-dev prd-mysql-m25 backup
--- ssh yyy-dev ---
ip = 10-10-10-1
error = backup failed 
date = $(date)" | /usr/sbin/ssmtp -v bug.fyi@mail.local
fi

# demos
echo -e 'Subject: test\n\nTesting ssmtp' | sendmail -v bug.fyi@mail.local
echo -e "this is the mail body" | mail -s 'Subject of ssmtp' bug.fyi@mail.local

# apt install ssmtp
apt install ssmtp
sh -ec 'printf "Subject: crond job01\n\n" && echo "job $(date)"' 2>&1 | /usr/sbin/ssmtp -v bug.fyi@mail.local
sh -ec 'printf "Subject: hello world\n\n" && echo "123 $(date)"' 2>&1 | tee -a /tmp/cron_test1.log | /usr/sbin/ssmtp -v bug.fyi@mail.local

(printf "Subject: hello world\n\n" && sh -c 'echo body123') 2>&1 | tee -a /tmp/cron_test1.log | /usr/sbin/ssmtp -v bug.fyi@mail.local

(printf "Subject: WB-gp6db-XZ daily backup\n\n" && /root/myjob.sh) 2>&1 | /usr/sbin/ssmtp -v bug.fyi@mail.local

```

- crontab -l / -e
```conf
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# m h  dom mon dow   command
```


#### configuration
- /etc/ssmtp/ssmtp.conf
> https://wiki.archlinux.org/title/SSMTP

```conf
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=displayname

# The place where the mail goes. The actual machine name is required no 
# MX records are consulted. Commonly mailhosts are named mail.domain.com
#mailhub=mail
mailhub=smtpdm.aliyun.com:465
# Use implicit TLS (port 465). When using port 587, change UseSTARTTLS=Yes
TLS_CA_FILE=/etc/ssl/certs/ca-certificates.crt
UseTLS=Yes
UseSTARTTLS=No

# Where will the mail seem to come from?
#rewriteDomain=

# The full hostname
#hostname=smtpdm.aliyun.com

# Username/Password
AuthUser=sys-message@mail.local
AuthPass=password
AuthMethod=LOGIN

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=NO
# Note: Take note, that the shown configuration is an example for Gmail, You may have to use other settings. # If it is not working as expected read the man page ssmtp(8), please.
```

#### Create aliases for local usernames (optional)
- /etc/ssmtp/revaliases
> https://wiki.archlinux.org/title/SSMTP

```conf
root:sys-message@mail.local
dev:sys-message@mail.local
```


- /etc/ssmtp/ssmtp.conf
> ON centos stream 9 `dnf install by EPEL`

```conf
mailhub=smtp.mail.local:465
AuthUser=235*****337@mail.local
AuthPass=authorized-code
# Use SSL/TLS to send secure messages to server.
UseTLS=YES
#IMPORTANT: The following line is mandatory for TLS authentication
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
```