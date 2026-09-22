import csv
import os
import db
from pathlib import Path
import logging

import sftp
import argparse
from datetime import datetime


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
log = logging.getLogger(__name__)

# During testing set this to true to prevent committing data
DEBUG_ROLLBACK = False
if DEBUG_ROLLBACK:
    log.warning("DEBUG Rollback flag is turned on. Data will not be committed.")

def write_csv(csv_file, columns, results):
    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        writer.writerow(columns)
        writer.writerows(results)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--runtime', help="Timestamp in ISO format (YYYY-MM-DDTHH-MM-SS)", default=datetime.now().strftime("%Y-%m-%dT%H-%M-%S"))
    args = parser.parse_args()
    runtime = args.runtime

    outdir = os.path.join(Path.cwd() / "output")
    os.makedirs(outdir, exist_ok=True)

    # Dataload structure defined here
    # For example a csv file is defined, a dml script for setup of the records, and export query for writing to the csv, and an update sent to be run after completion.
    exports = [
        {"name": "person", "csv": os.path.join(outdir, f"001_person_{runtime}.csv"), "dml": "sql/dataload/person_dml.sql", "export": "sql/dataload/person_export.sql", "sent": "sql/dataload/person_sent.sql"},
        {"name": "address", "csv": os.path.join(outdir, f"005_address_{runtime}.csv"), "dml": "sql/dataload/address_dml.sql", "export": "sql/dataload/address_export.sql", "sent": "sql/dataload/address_sent.sql"},
        {"name": "phone", "csv": os.path.join(outdir, f"010_phone_{runtime}.csv"), "dml": "sql/dataload/phone_dml.sql", "export": "sql/dataload/phone_export.sql", "sent": "sql/dataload/phone_sent.sql"},
        {"name": "email", "csv": os.path.join(outdir, f"015_email_{runtime}.csv"), "dml": "sql/dataload/email_dml.sql", "export": "sql/dataload/email_export.sql", "sent": "sql/dataload/email_sent.sql"},
        {"name": "degree", "csv": os.path.join(outdir, f"045_degree_{runtime}.csv"), "dml": "sql/dataload/degree_dml.sql", "export": "sql/dataload/degree_export.sql", "sent": "sql/dataload/degree_sent.sql"},
        {"name": "sports", "csv": os.path.join(outdir, f"050_sports_{runtime}.csv"), "dml": "sql/dataload/athletes_dml.sql", "export": "sql/dataload/athletes_export.sql", "sent": "sql/dataload/athletes_sent.sql"},
        {"name": "constituent", "csv": os.path.join(outdir, f"065_constituent_{runtime}.csv"), "dml": "sql/dataload/const_dml.sql", "export": "sql/dataload/const_export.sql", "sent": "sql/dataload/const_sent.sql"}
    ]

    # File array for each of the dataload csv files created
    log.info("Slate Dataload Job %s", runtime)
    files = []
    with db.get_conn() as conn:
        try:
            # create dataload temp with active users for dataload processing
            log.info("Executing dataload populate tmp table")
            with open("sql/dataload/dataload_tmp_const.sql", "r") as f:
                stmt = f.read()
                db.exec(conn, stmt)
            with open("sql/dataload/dataload_tmp.sql", "r") as f:
                stmt = f.read()
                db.exec(conn, stmt)

            # Merge data and write csv
            for export in exports:
                log.info("Executing export: %s", export)
                with open(export['dml'], 'r') as f:
                    stmt = f.read()
                    log.debug("Executing export dml: %s", stmt)
                    db.exec(conn, stmt)
                with open(export['export'], 'r') as f:
                    stmt = f.read()
                    columns, results = db.query_results(conn, stmt)
                    log.debug("Executing export dml: %s", stmt)
                    csv = export['csv']
                    write_csv(csv, columns, results)
                    files.append(csv)

            # SFTP files to slate
            #sftp.upload_files(files, "incoming/student")

            # Update the send flag for the imports
            for export in exports:
                with open(export['sent'], 'r') as f:
                    stmt = f.read()
                    db.exec(conn, stmt)

            if DEBUG_ROLLBACK:
                conn.rollback()
            else:
                conn.commit()
        except Exception:
            conn.rollback()
            raise



if "__main__" == __name__:
    main()