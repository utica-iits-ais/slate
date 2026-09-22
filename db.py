import oracledb
from oracledb import Connection
import os

# env assignment db
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_DSN = os.getenv("DB_DSN")

def get_conn():
    return oracledb.connect(user=DB_USER, password=DB_PASSWORD, dsn=DB_DSN)

def exec(conn: Connection, stmt):
    with conn.cursor() as cur:
        cur.execute(stmt)

def query_results(conn: Connection, stmt):
    with conn.cursor() as cur:
        cur.execute(stmt)
        # Fetch column names
        columns = [col[0] for col in cur.description]
        # Fetch all results
        results = cur.fetchall()
        return columns, results