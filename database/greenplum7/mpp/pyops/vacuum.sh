set -e

# vacuum_bloating (At minute 50 past every 2nd hour from 10 through 23 and 3)
# 50 10-23/2,3 * * * sh /mpp/gpadmin/pyops/bloating_doctor.sh 2>&1 | tee -a /tmp/cron_vacuum_bloating.log

printf -- "\n---- $(date) ----\n"
# uv python install python3.12
source /mpp/gpadmin/pyops/venv/bin/activate
python /mpp/gpadmin/pyops/bloat_doctor.py
