# python3.11 -m ensurepip
# python3.11 -m pip install psycopg[binary,pool]
# /usr/bin/python3.11 vacuum.py
# python3.11 -m pip install psycopg[binary,pool] -i http://mirrors.cloud.aliyuncs.com/pypi/simple/ --trusted-host mirrors.cloud.aliyuncs.com
# import psycopg
import psycopg_pool as pool
import datetime
"""
pypy -m pip install psycopg[binary,pool] # v3
`with conn_pool.connection() as conn:`
"""
# import pandas as pd
# VACUUM ANALYZE
def run_vacuum_analyse(conn_pool):
    query = "VACUUM (ANALYZE, VERBOSE);"
    with conn_pool.connection() as conn:
        with conn.cursor() as curs:
            curs.execute(query)


def get_gp_bloat_diag(conn_pool):
    query = "select (bdinspname || '.' || bdirelname) as full_name, * from gp_toolkit.gp_bloat_diag"
    with conn_pool.connection() as conn:
        with conn.cursor() as curs:
            curs.execute(query)
            bloated_tables = curs.fetchall()
            return bloated_tables


def get_bloated_tables(conn_pool):
    """
    Gets a list of bloated tables from the Greenplum database.
    pg_catalog.pg_stat_user_tables
    pg_catalog.pg_stat_all_tables
    gp_toolkit.gp_bloat_diag
    """

    query = """
        SELECT
            (schemaname || '.' || relname) as full_name,
            relname,
            schemaname,
            n_dead_tup,
            n_live_tup
        FROM
            pg_stat_all_tables
        WHERE
            n_dead_tup > 50000
            AND n_live_tup > 0
            AND (n_dead_tup / n_live_tup) > 2
        order by n_live_tup desc
        limit 100
    """

    with conn_pool.connection() as conn:
        with conn.cursor() as curs:
            curs.execute(query)
            bloated_tables = curs.fetchall()
            return bloated_tables


def run_vacuum(conn_pool, table_name):
    """Runs vacuum on the specified table."""

    query = f"""
        --set autocommit on;
        --COMMIT;
        vacuum(full, verbose, analyze) {table_name};
        --set autocommit off;
    """

    with conn_pool.connection() as conn:
        with conn.cursor() as curs:
            conn.autocommit = True
            logger(conn.autocommit)
            curs.execute(query)


def check_statement_timeout(conn_pool):
    query = f'show statement_timeout;SELECT 1; SELECT 2;'
    with conn_pool.connection() as conn:
        logger(conn.autocommit)
        with conn.cursor() as curs:
            conn.autocommit = True
            curs.execute(query)
            logger(curs.fetchall())


def logger(*msg):
    logs = [str(s) for s in msg]
    print(f'{datetime.datetime.now()}>>', ' '.join(logs), flush=True)


def run_maintain(dbname: str, conn_pool):
    logger('---> run for ', dbname)
    for i in range(0, 1):
        check_statement_timeout(conn_pool)
    logger(conn_pool.get_stats())

    # VACUUM ANALYZE, already vaccumed on backup
    #run_vacuum_analyse(conn_pool)

    gp_diag_tables = get_gp_bloat_diag(conn_pool)
    for table_name in gp_diag_tables:
        logger(f"Bloated table: {table_name[0]}")
        run_vacuum(conn_pool, table_name[0])

    bloated_tables = get_bloated_tables(conn_pool)

    for table_name in bloated_tables:
        logger(f"Bloated table: {table_name[0]}")
        run_vacuum(conn_pool, table_name[0])

    conn_pool.close()
    logger('>> finish to vacuum bloated tables on', dbname)


def main():
    """The main function."""
    for db in ['postgres', 'dw01', 'wbdata']:
        with pool.ConnectionPool(
            conninfo=f"postgresql://gpadmin@localhost:5677/{db}?application_name=doctor",
            min_size=0,
            max_size=2,
            timeout=5,
            kwargs={
                'options': '-c statement_timeout=7200000'}
        ) as conn_pool:
            run_maintain(db, conn_pool)


if __name__ == "__main__":
    main()