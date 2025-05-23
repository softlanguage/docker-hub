## install on linux
> https://packagecloud.io/citusdata/community

```sh
# jammy compatibile with ubuntu 24 (nobel, based on debian trixie)
# https://packagecloud.io/citusdata/community/packages/ubuntu/jammy/postgresql-16-citus-12.1_12.1.6.citus-1_amd64.deb
wget --content-disposition "https://packagecloud.io/citusdata/community/packages/ubuntu/jammy/postgresql-16-citus-12.1_12.1.6.citus-1_amd64.deb/download.deb?distro_version_id=237"

apt install ./postgresql-16-citus-12.1_12.1.6.citus-1_amd64.deb
psql -e 'alter system set shared_preload_libraries="citus"';
```
