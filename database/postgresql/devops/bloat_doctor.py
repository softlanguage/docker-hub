"""
pypy -m pip install psycopg[binary,pool] # v3
`with conn_pool.connection() as conn:`
"""
import psycopg_pool as pool
import psycopg
import datetime

def run_vacuum_analyse(conn_pool):
    query = "VACUUM (ANALYZE, VERBOSE);"
    with conn_pool.connection() as conn:
        with conn.cursor() as curs:
            curs.execute(query)

def get_bloated_tables(conn_pool):
    """
    Gets a list of bloated tables from the Greenplum database.
    pg_catalog.pg_stat_user_tables
    pg_catalog.pg_stat_all_tables
    gp_toolkit.gp_bloat_diag
    """

    query = """
        select * from (
SELECT
    (schemaname || '.' || relname) as full_name,
    schemaname,
    relname,
    pg_size_pretty(pg_relation_size(relid)) AS current_size,
    n_live_tup,
    n_dead_tup,
    CASE WHEN n_live_tup > 0 THEN round((n_dead_tup::float / n_live_tup::float)::numeric, 4) END AS dead_tup_ratio,
    last_autovacuum,
    last_autoanalyze
FROM
    pg_stat_user_tables) as bloated
where dead_tup_ratio >= 1 and n_dead_tup > 50000
ORDER BY
    n_dead_tup DESC NULLS LAST;
    """

    with conn_pool.connection() as conn:
        with conn.cursor() as curs:
            curs.execute(query)
            bloated_tables = curs.fetchall()
            return bloated_tables


def run_analyse(conn_pool, table_name):
    """Runs vacuum on the specified table."""

    query = f"""
        --set autocommit on;
        --COMMIT;
        ANALYZE VERBOSE {table_name};
        --set autocommit off;
    """
    try:
        with conn_pool.connection() as conn:
            with conn.cursor() as curs:
                conn.autocommit = True
                logger(conn.autocommit)
                curs.execute(query)
                logger(f"[Analyse] {table_name} done")
    except psycopg.errors.LockNotAvailable:
        logger(f"[Analyse] Lock timeout:  {table_name}, do next..")
    except Exception as e:
        logger(f"[Analyse] An error occurred: {str(e)}")

def run_vacuum(conn_pool, table_name):
    """Runs vacuum on the specified table."""

    query = f"""
        --set autocommit on;
        --COMMIT;
        vacuum(full, verbose, analyze) {table_name};
        --set autocommit off;
    """
    try:
        with conn_pool.connection() as conn:
            with conn.cursor() as curs:
                conn.autocommit = True
                logger(conn.autocommit)
                curs.execute(query)
    except psycopg.errors.LockNotAvailable:
        logger(f"Lock timeout:  {table_name}, try analyse..")
        run_analyse(conn_pool, table_name)
    except Exception as e:
        logger(f"An error occurred: {str(e)}")


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
    logger(conn_pool.get_stats())

    bloated_tables = get_bloated_tables(conn_pool)

    for table_name in bloated_tables:
        logger(f"Bloated table: {table_name[0]}")
        run_vacuum(conn_pool, table_name[0])

    conn_pool.close()
    logger('>> finish to vacuum bloated tables on', dbname)


def main():
    """The main function."""
    for db in ['postgres', 'wbdata']:
        with pool.ConnectionPool(
            conninfo=f"postgresql://postgres@localhost:5677/{db}?application_name=doctor",
            min_size=0,
            max_size=2,
            timeout=5,
            kwargs={
                'options': '-c lock_timeout=5000 -c statement_timeout=600000 -c statement_timeout=7200000'}
        ) as conn_pool:
            run_maintain(db, conn_pool)


if __name__ == "__main__":
    main()
