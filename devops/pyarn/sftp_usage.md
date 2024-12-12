#### ftpuser

```sh
# create ftpuser and set password
useradd -m -s /sbin/nologin ftpuser
passwd ftpuser

# config sshd_config & restart sshd
sshd -t
systemctl restart ssh

# client
sftp ftpuser@remote-ssh-server
```

- etc/ssh/sshd_config
```conf
# /etc/ssh/sshd_config
# override default of no subsystems
#Subsystem sftp	/usr/lib/openssh/sftp-server
Subsystem sftp  internal-sftp

# user
Match User ftpuser
ForceCommand internal-sftp
PasswordAuthentication yes
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
PermitTunnel no
```
