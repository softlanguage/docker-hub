#!/bin/dash
#archive_mode = 'on/off'
#archive_command = '/var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh %p %f do_archive'
#restore_command = '/var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh %p %f do_restore'
#recovery_target_time = '2025-01-17 07:23:00 UTC' #  in UTC TimeZone
#recovery_target_time = '2025-01-17 15:27:00+8' # in UTC+8 TimeZone
#chmod +x /var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh

set -e
dir_archived=/var/lib/postgresql/backup/archivedWAL
# 1=$p,WAL_location, 2=%f,wal_leafname_name
wal_location=$1
wal_leafname=$2
arg_cleanup=$4
# remainder_base for wal_leafname: [4~999]
remainder_base=5

# wal_leafname maybe: 00000001000000420000003D, 000**.history, 000**.backup
case "$wal_leafname" in
  *[!0-9a-fA-F]*)
    # wal_leafname is 000**.history or 000**.backup, not a Hex string
    hex_leafname=${wal_leafname%%.*}
    echo "$(date +%F\ %T) -- %f_has.dot, dir_rem=d000 %f=$wal_leafname, hex.LSN=$hex_leafname"
    remainder_value="000"
    ;;
  *)
    # "$wal_leafname is a Hex string"
    # dash-shell get 10bytes, max=15bytes, not support ${str:-15}
    hex_offset=$(( ${#wal_leafname} -9 ))
    if [ $hex_offset -gt 0 ]; then
      hex_leafname=$(expr substr "$wal_leafname" $hex_offset 10)
    else
      hex_leafname=$wal_leafname
    fi
    remainder_value="$((0x$hex_leafname % $remainder_base + 1))"
    ;;
esac

# sub folder by remainder of wal_LSN_%f 
dir_rem=$(printf "d%03d" "$remainder_value")
# location of archived WAL
#printf "
## $(date +%F\ %T)
#wal_location=$wal_location
#wal_leafname=$wal_leafname
#hex_leafname=$hex_leafname
#remainder_base=$remainder_base
#dir_rem=$dir_rem
#" >> $dir_archived/debug.log

# Create the directory if it doesn't exist
if [ ! -d "$dir_archived/$dir_rem" ]; then
  mkdir -p "$dir_archived/$dir_rem"
fi

do_archive(){
  #cp -fa $wal_location $dir_archived/$dir_rem/$wal_leafname
  zstd -c $wal_location > $dir_archived/$dir_rem/$wal_leafname.zst
  # zstd has better performance than gzip

  # $4=cleanup
  # archive_command='archive_restore_wal.sh %p %f do_archive cleanup'
  if [ "$arg_cleanup" = "cleanup" ] && [ "$remainder_value" = "$remainder_base" ]; then
    echo "$(date +%F\ %T) -- cleanup"
    find $dir_archived -maxdepth 2 -name '*.zst' -type f -mtime +3 -print -exec rm -rf {} \;
    # 3days ago: -mtime +3 , 180mins ago: -mmin +180
  fi
}

# touch recovery.signal to restore
do_restore(){
  #cp $dir_archived/$dir_rem/$wal_leafname $wal_location
  zstd -c -d $dir_archived/$dir_rem/$wal_leafname.zst > $wal_location
  echo "$(date +%F\ %T) -- restore from $dir_rem/$wal_leafname.zst"
}

# mock by ls | xargs
# ls 0000000* | xargs -I{} sh ../archive_restore_wal.sh /backup/archive_wal/pg_wal/{} {} do_archive 
# call do_archive/do_restore
$3

#archive_mode = 'on/off'
#archive_command = '/var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh %p %f do_archive'
#restore_command = '/var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh %p %f do_restore'
#recovery_target_time = '2025-01-17 07:23:00 UTC' #  in UTC TimeZone
#recovery_target_time = '2025-01-17 15:27:00+8' # in UTC+8 TimeZone
#chmod +x /var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh
# ls 0000000* | xargs -I{} sh ../archive_restore_wal.sh /backup/archive_wal/pg_wal/{} {} do_archive

#### postgresql.conf ####
# wal_compression = on, full_page_writes = on
# psql -c 'ALTER SYSTEM SET wal_compression = on; SELECT pg_reload_conf();'
# pg_resetwal --wal-segsize=64 # set=64MB, psql -c 'show wal_segment_size;'