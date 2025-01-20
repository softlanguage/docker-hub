#### s3fs-fuse 

> https://github.com/s3fs-fuse/s3fs-fuse
> https://github.com/kahing/goofys
> https://rclone.org

- aliyun OSS
> https://github.com/aliyun/ossfs

> https://help.aliyun.com/zh/oss/developer-reference/mount-oss-buckets-to-local-file-systems-by-using-amazon-s3-protocols

```sh
# security credentials
touch /etc/passwd-s3fs 
chmod 0600 /etc/passwd-s3fs
echo "access-key:sec" >> /etc/passwd-s3fs

# mount with AK in /etc/passwd-s3fs 
s3fs mybucket /mpp/s3_zyb-backup  -ourl=http://oss-cn-hangzhou-internal.aliyuncs.com

# mount with AK in /mnt/pass_s3zyb-backup
s3fs mybucket /mpp/s3_zyb-backup -o passwd_file=/mnt/pass_s3zyb-backup -ourl=http://oss-cn-hangzhou-internal.aliyuncs.com

# mount `mybucket` to `/mnt/mountpoint` in fstab
mybucket /mnt/mountpoint fuse.s3fs _netdev,allow_other,use_path_request_style,url=https://url.to.s3/ 0 0
mybucket /mnt/mountpoint fuse.s3fs _netdev,allow_other,use_path_request_style,url=http://oss-cn-hangzhou-internal.aliyuncs.com 0 0

```

```shell
# centOS stream8
dnf install https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/s/s3fs-fuse-1.95-1.el8.x86_64.rpm

# centos stream9
dnf install https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/Packages/s/s3fs-fuse-1.95-1.el9.x86_64.rpm


# --- apt info s3fs -----
s3fs examplebucket /tmp/oss-bucket -o passwd_file=$HOME/.passwd-s3fs -ourl=http://oss-cn-hangzhou.aliyuncs.com

```
