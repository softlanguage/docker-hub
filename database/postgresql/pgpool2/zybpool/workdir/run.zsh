set -e

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"
rm -f $workdir/socks/.s.* && sleep 1
exec pgpool -f $workdir/pgpool.conf -m fast -n -D # -m fast & disown %-  #-d
# reload pool_passwd
# pgpool -f /workdir/pgpool.conf reload

# run by root>
#chown -R postgres:postgres $workdir 
#runuser -u postgres --  pgpool -f $workdir/pgpool.conf -n -D & disown %-  #-d
