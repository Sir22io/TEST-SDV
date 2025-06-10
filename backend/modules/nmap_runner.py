import subprocess
import sqlite3
from datetime import datetime

def run_nmap(target):
    now = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    result = subprocess.run(
        ["nmap", "-A", "-T4", target],
        capture_output=True, text=True
    )
    output = result.stdout
    # Save to DB
    conn = sqlite3.connect("db/toolbox.db")
    cur = conn.cursor()
    cur.execute("INSERT INTO scans (target, result, date) VALUES (?, ?, ?)", (target, output, now))
    conn.commit()
    conn.close()
    return output, now
