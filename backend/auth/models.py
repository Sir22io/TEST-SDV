import sqlite3

def init_db():
    conn = sqlite3.connect("db/toolbox.db")
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password_hash TEXT,
            role TEXT
        )
    ''')
    cur.execute('''
        CREATE TABLE IF NOT EXISTS scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            target TEXT,
            result TEXT,
            date TEXT
        )
    ''')
    conn.commit()
    conn.close()

def add_user(username, password_hash, role="user"):
    conn = sqlite3.connect("db/toolbox.db")
    cur = conn.cursor()
    cur.execute("INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)",
                (username, password_hash, role))
    conn.commit()
    conn.close()

def get_user(username):
    conn = sqlite3.connect("db/toolbox.db")
    cur = conn.cursor()
    cur.execute("SELECT id, username, password_hash, role FROM users WHERE username=?", (username,))
    row = cur.fetchone()
    conn.close()
    if row:
        return {"id": row[0], "username": row[1], "password_hash": row[2], "role": row[3]}
    return None
