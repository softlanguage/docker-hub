set -e

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"
pgpool -f $workdir/pgpool.conf -n -D # & disown %-  #-d

# run by root>
#chown -R postgres:postgres $workdir 
#runuser -u postgres --  pgpool -f $workdir/pgpool.conf -n -D & disown %-  #-d
