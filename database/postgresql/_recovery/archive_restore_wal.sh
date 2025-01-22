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
# dash-shell get 10bytes, max=15bytes, not support ${str:-15}
hex_leafname=$(expr substr "$wal_leafname" $(expr length "$wal_leafname" - 9) 10)
# remainder for wal_leafname: [10~999]
remainder_base=5
dir_rem=$(printf "d%03d\n" "$((0x${hex_leafname} % $remainder_base + 1))")
# location of archived WAL
#printf "
## $(date +%F\ %T)
#wal_location=$wal_location
#wal_leafname=$wal_leafname
#hex_leafname=$hex_leafname
#remainder_base=$remainder_base
#dir_rem=$dir_rem
#" >> $dir_archived/debug.log

do_archive(){
    mkdir -p $dir_archived/$dir_rem
    #cp -fa $wal_location $dir_archived/$dir_rem/$wal_leafname
    zstd -c $wal_location > $dir_archived/$dir_rem/$wal_leafname.zst
}

do_restore(){
    #cp $dir_archived/$dir_rem/$wal_leafname $wal_location
    zstd -c -d $dir_archived/$dir_rem/$wal_leafname.zst > $wal_location
}

# call do_archive/do_restore
$3

#archive_mode = 'on/off'
#archive_command = '/var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh %p %f do_archive'
#restore_command = '/var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh %p %f do_restore'
#recovery_target_time = '2025-01-17 07:23:00 UTC' #  in UTC TimeZone
#recovery_target_time = '2025-01-17 15:27:00+8' # in UTC+8 TimeZone
#chmod +x /var/lib/postgresql/backup/archivedWAL/archive_restore_wal.sh
