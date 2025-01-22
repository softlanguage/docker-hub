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
# dash-shell get 10bytes, max=15bytes, not support ${str:-15}
# wal_leafname maybe: 00000001000000420000003D or 00000001000000420000003D.0011D718.backup
hex_wal_name="${wal_leafname%%.*}" 
hex_leafname=$(expr substr "$hex_wal_name" $(expr length "$hex_wal_name" - 9) 10)
# remainder for wal_leafname: [10~999]
remainder_base=5
remainder_value="$((0x$hex_leafname % $remainder_base + 1))"
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
