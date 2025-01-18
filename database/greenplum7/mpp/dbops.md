
- gpbackup & restore

```txt
# gpbackup & gprestore

`gpbackup --backup-dir=$HOME/bak01 --dbname uat_sell --jobs 3`
`gprestore --backup-dir $HOME/bak01/ --redirect-db new_sell --jobs 3`

https://techdocs.broadcom.com/us/en/vmware-tanzu/data-solutions/tanzu-greenplum-backup-and-restore/1-30/greenplum-backup-and-restore/admin_guide-managing-backup-gpbackup-incremental.html


# greenplum-disaster-recovery
https://techdocs.broadcom.com/us/en/vmware-tanzu/data-solutions/tanzu-greenplum-disaster-recovery/1-1/gp-disaster-recovery/installing_gpdr.html
```
