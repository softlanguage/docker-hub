set -e

# ssh-keygen
# cp -a ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
# chmod 0600 ~/.ssh/authorized_keys
# ssh gp7s1.local
gpinitsystem -c mpp_init.conf -h hostlist \
	--lc-collate=zh_CN.utf8 --locale=zh_CN.utf8 \
	--max_connections=511

#--su-password=passxx
# to delete entire system:
# gpdeletesystem
# will delete all files of master and segs
# -- psql ---
# alter user gpadmin with password 'passxx';
# -- pg_hba.conf --
# host 	all	all	all	md5
