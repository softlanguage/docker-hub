#!/usr/bin/env python3
"""sh
# with lock and no-wait 
# flock -n /run/lock/pyarn-cron-job1.lock -c 'sh -e /opt/cron-job1.sh' 2>&1 | tee -a /tmp/cron-test02.log

set -e
printf -- "\n\n-- start on $(date) --\n"

if ! docker exec -i clickhouse-xlog /ckdb/xlog_bearer.py; then
echo "Faild to bear logs from PG to Clickhouse"
printf "Subject:[Failed] dev-dw01.Clickhouse bears logs from PG\n
--- Falied to bear logs ---
host = dw01.dev
error = Faild to bear logs from PG to Clickhouse
cron = sh -e /ckdb/cron_bear_xlog.sh 2>&1 | tee -a /tmp/ckdb_bear_xlog.log
full_log = tail -c 10k /tmp/ckdb_bear_xlog.log
date = $(date)\n" | /usr/sbin/ssmtp -v bug.fyi@mail-domain

fi

printf -- "-- finish by $(date) --\n\n"
"""


from datetime import datetime, timedelta
import subprocess
import time

def logger(*msg):
    logs = [str(s) for s in msg]
    print(f"\n{datetime.now()} -->", " ".join(logs), flush=True)


def cmd_stdin_pipe():
    # stdin test
    cmd = subprocess.Popen("cat", stdin=subprocess.PIPE)
    stdin = cmd.stdin
    for i in range(1, 11):
        stdin.write(f"Hello, message-{i}!\n".encode("utf-8"))
    stdin.close()
    cmd.wait()


# -- EOF for SQL
def query_ck_xlog(*args) -> str:
    # my $r1 = qx/clickhouse-client -d prd_dev_xlog -mn "@_"/;
    cmd = ["clickhouse-client", "-d", "prd_dev_xlog", "-mn", "-q"] + list(args)
    logger(cmd)
    output = subprocess.check_output(cmd)
    return output.decode("utf-8")


def exec_postgresql(sql) -> str:
    cmd = ["psql", "-dpostgres", "-h10.5.4.32", "-p5432", "-Udev", "-c", sql]
    logger(cmd)
    output = subprocess.check_output(cmd, env={"PGPASSWORD": "xxx"})
    return output.decode("utf-8")


def get_max_today_in_ck(yesterday):
    # yesterday = datetime.today().__format__("%Y%m%d")
    sql2 = f"""
with (select ifNull(max(today), 0) from app_logs where today<={yesterday}) as maxday
select maxday as maxday_ck, count(1) as cnt_ck, 
(select count(1) from pg_xlog.app_logs where today=maxday) as cnt_pg,
(select ifNull(min(today), 0) from pg_xlog.app_logs where today>maxday and today<={yesterday}) as bear_day
from app_logs where today=maxday;
"""
    r1 = query_ck_xlog(sql2)
    # parse result to: maxday_ck, cnt_ck, cnt_pg, bear_day_pg
    numbers = r1.rstrip("\n").split("\t")

    if len(numbers) != 4:
        raise ValueError("❌ Check count of query result: ", numbers)
    if numbers[1] != numbers[2]:
        raise ValueError(f"❗ Warning: clickhouse={numbers[1]}, but pgdb={numbers[2]}")

    for i in range(4):
        numbers[i] = int(numbers[i])

    logger(f"check result is: {numbers}")
    return numbers


bear_limit = 5


def bearing_xlog(workday: int):
    sql2 = f"""
INSERT INTO prd_dev_xlog.app_logs SELECT 
id, `uuid`, title, content, operate_type, biz_id, biz_code, biz_name, url, service_ip, client_ip, 
req_control, req_method, req_time, user_id, app_id, author, created, editor, modified, today, cost_time
FROM pg_xlog.app_logs
where today={workday};
"""
    query_ck_xlog(sql2)


def pg_xlog_shrink(shrink_day: int):
    t1 = datetime.strptime(str(shrink_day), "%Y%m%d")
    delta2 = timedelta(days=10)
    retention = (t1 - delta2).__format__("%Y%m%d")
    sql2 = f"delete from log.app_logs where today < {retention};"
    logger(exec_postgresql(sql2))


def bear_logs():
    yesterday = (datetime.today() - timedelta(days=1)).__format__("%Y%m%d")
    yesterday = int(yesterday)
    logger("yesterday is", yesterday)
    nnn = get_max_today_in_ck(yesterday)

    maxday_ck, cnt_ck, cnt_pg, bear_day_pg = tuple(nnn)
    logger(
        f"maxday_ck={maxday_ck}, count_ck={cnt_ck}, count_pg={cnt_pg}, bearing_day_pg={bear_day_pg}"
    )
    workday = bear_day_pg if cnt_ck >= cnt_pg else maxday_ck

    if workday > 0 and workday <= yesterday:
        logger(f"start to bear logs of {workday}")
        bearing_xlog(workday)
        # try next day by bear_logs
        global bear_limit
        bear_limit -= 1
        if bear_limit > 0:
            bear_logs()
    else:
        shink_day = workday if workday > 0 else yesterday
        pg_xlog_shrink(shink_day)
        logger("Great, [app_logs] well done ✅ ")


def ping():
    ck1 = "select 'Hello Clickhouse version of' as hello, version();"
    logger(query_ck_xlog(ck1))
    sql2 = "select 'Hello Clickhouse version of' as hello, version();"
    logger(exec_postgresql(sql2))
    ck_list = [
        "DESCRIBE TABLE pg_xlog.app_logs;",
        "DESCRIBE TABLE pg_xlog.wblog;",
    ]
    for ck_sql in ck_list:
        try:
            query_ck_xlog(ck_sql)
        except Exception as e:
            # pg-engine in clickhouse maybe failed
            print(">> Ping failed", e)
            time.sleep(1)


def bear_pg_wblog():
    yesterday = datetime.today() - timedelta(days=1)
    bearing_day = yesterday.__format__("%Y%m%d")
    ck_sql = f"""
insert INTO prd_dev_xlog.wblog SELECT * from (
with (select ifNull(max(today), 0) from wblog where today<={bearing_day}) as maxday,
(select ifNull(max(today), 0) from pg_xlog.wblog where today<={bearing_day}) as bearing_day
select id, user_id, module_id, label_name, click_event, app_version, created, today
FROM pg_xlog.wblog where today > maxday and today <=bearing_day);
"""
    query_ck_xlog(ck_sql)
    shrink_day = (yesterday - timedelta(days=100)).__format__("%Y%m%d")
    pgsql = f"delete from log.wblog where today < {shrink_day};"
    logger(f"shrink log.wblog on pgdb, {shrink_day}: {pgsql}")
    exec_postgresql(pgsql)
    logger("Great, [wblog] well done ✅ ")


def main():
    """The main function."""
    ping()
    bear_logs()
    bear_pg_wblog()


if __name__ == "__main__":
    main()
