
import db

def main():

    with db.get_conn() as conn:
        print(conn.db_name)


if "__main__" == __name__:
    main()