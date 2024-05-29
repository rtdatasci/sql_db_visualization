import sqlite3


# Ensure the connection is closed if open
try:
    conn = sqlite3.connect('samples.db')
    conn.close()
except sqlite3.Error as e:
    print(e)


import os

# Path to the database file
db_path = 'samples.db'

# Check if the file exists
if os.path.exists(db_path):
    try:
        os.remove(db_path)
        print(f"Deleted {db_path} successfully.")
    except OSError as e:
        print(f"Error: {e.strerror}")
else:
    print(f"{db_path} does not exist.")