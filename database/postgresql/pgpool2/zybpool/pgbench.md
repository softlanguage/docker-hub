- pgbench and sql

```sh
export PGPASSWORD=Read123
pgbench -i -d demo #need dbadmin, to init
pgbench -h10.8.8.220 -p5678 -Ureadonly -n -S -c 32 -C -S -T 300 demo
pgbench -h10.8.8.220 -p5678 -Ureadonly -n -S -c 32 -C -S -T 300 demo
```

```sql
/*NO LOAD BALANCE*/ -- only run on primary
select inet_server_addr()::text, now()::text as ip_time
for update;

-- user # host postgres sr_check_user 10.0.0.0/8 trust # pg_hba.conf
CREATE ROLE sr_check_user WITH NOINHERIT LOGIN;
-- psql
show pool_pools;
```

- pgpool.conf options 


```conf
# pool options
num_init_children = 195
max_pool = 1
child_life_time = 300
child_max_connections = 990
connection_life_time = 0
client_idle_limit = 90
```

```conf
listen_addresses = '0.0.0.0'              # Listen on all available IP addresses
port = 5678                         # Port for pgpool to listen on
unix_socket_directories = '/tmp'
#pcp_socket_dir = '/workdir/socks'
pcp_listen_addresses = '127.0.0.1'
pcp_port = 9898
num_init_children = 511	# Maximum Number of concurrent sessions allowed
max_pool = 1		# Number of connection pool caches per connection
# Enable dynamic pool sizing
connection_cache = on
process_management_mode = static
#process_management_mode = dynamic
#process_management_strategy = gentle
#min_spare_children = 10
#max_spare_children = 100

# Logging settings
log_destination = 'stderr'      # Log to standard error
log_connections = true          # Log connections
log_hostname = true             # Log hostname

# Authentication settings
# enable_pool_hba = true          # Enable pool_hba.conf for authentication
# pool_passwd = 'pool_passwd'      # Password file for pool_hba.conf
# pool_passwd= ''

# host nodes
backend_hostname0 = '10.16.1.255'   # Hostname of the primary (write) PostgreSQL server
backend_port0 = 5433                # Port of the primary PostgreSQL server
backend_flag0 = 'ALWAYS_PRIMARY|DISALLOW_TO_FAILOVER'    # ALLOW_TO_FAILOVER, DISALLOW_TO_FAILOVER, ALWAYS_PRIMARY
backend_weight0 = 0                 # 0=no readonly query

backend_hostname1 = '10.16.2.0'     # Hostname of the first standby (read-only) PostgreSQL server
backend_port1 = 5433                # Port of the first standby PostgreSQL server
backend_flag1 = 'DISALLOW_TO_FAILOVER'    # ALLOW_TO_FAILOVER, DISALLOW_TO_FAILOVER, ALWAYS_PRIMARY
backend_weight1 = 1

# pg_hba.conf on primary and replicas must be trust
# host all postgres 10.8.8.220/32 trust
sr_check_user = 'sr_check_user'
sr_check_period = 3
sr_check_database = 'postgres'
delay_threshold = 512000

# sample
backend_clustering_mode = 'streaming_replication'
#auto_failback = on
                                   # Dettached backend node reattach automatically
                                   # if replication_state is 'streaming'.
#auto_failback_interval = 5
```
