- optimize
```sh
# pip install psycopg
python3.11 -m ensurepip
python3.11 -m pip install psycopg[binary,pool] -i http://mirrors.cloud.aliyuncs.com/pypi/simple/ --trusted-host mirrors.cloud.aliyuncs.com

# optimize
gpstop -r -M fast # restart
gpstop -u # to reload configs

<<'///'
# -- postgresql
autovacuum_max_workers = 3              # max number of autovacuum subprocesses
autovacuum_vacuum_scale_factor = 0.005  # fraction of table size before vacuum
autovacuum_analyze_scale_factor = 0.005 # fraction of table size before analyze
autovacuum_vacuum_cost_limit = 3000   
///

# greenplum v7.1
gpconfig -s autovacuum_max_workers
# Set the xxx setting to 100 on all segments and 10 on the coordinator:
gpconfig -c xxx -v 100 -m 10 # -v=all segments, -m=master/coordinator
gpconfig -s autovacuum_max_workers
gpconfig -c autovacuum_vacuum_scale_factor -v 0.005 -m 0.005
gpconfig -c autovacuum_analyze_scale_factor -v 0.005 -m 0.005
# gpconfig -c autovacuum_vacuum_cost_delay -v 5ms -m 5ms
gpconfig -c vacuum_cost_limit -v 3000  -m 3000
# gpconfig -c autovacuum_naptime -v 30 -m 30 #=30s, units is seconds.
# gpconfig -c autovacuum_vacuum_cost_limit -v 3000  -m 3000 # can't be modified
# EOF
# total memory is 8GB
gpconfig -c max_connections -v 511 -m 511
# random_page_cost = 1.1
gpconfig -c huge_pages -v off -m off
gpconfig -c shared_buffers -v 256MB -m 256MB
# effective_cache_size = 4GB
# maintenance_work_mem = 256MB
# work_mem = 2mb
# -- pg_wal
# max_wal_size=1GB
# max_slot_wal_keep_size=2GB
```