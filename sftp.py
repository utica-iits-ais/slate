import os
from pathlib import Path
from fabric import Connection

# Connection parameters
SFTP_HOST = os.getenv("SFTP_HOST")
SFTP_USER = os.getenv("SFTP_USER")
SFTP_KEY = os.path.join(Path.home() / ".ssh" / os.getenv("SFTP_KEY"))


def upload_file(local, remote):
    # Connect using private key
    with Connection(host=SFTP_HOST,user=SFTP_USER,connect_kwargs={"key_filename": SFTP_KEY}) as sftp:
        # Upload file
        result = sftp.put(local, remote=remote, preserve_mode=False)
        print(f"Uploaded {result.local} → {result.remote}")

def upload_files(local_files, remote_location):
    with Connection(host=SFTP_HOST,user=SFTP_USER,connect_kwargs={"key_filename": SFTP_KEY}) as sftp:
        for local_file in local_files:
            result = sftp.put(local_file, remote=f"{remote_location}/{Path(local_file).name}", preserve_mode=False)
            print(f"Uploaded {result.local} → {result.remote}")