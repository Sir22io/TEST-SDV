import bcrypt

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password: str, hash_pw: str) -> bool:
    return bcrypt.checkpw(password.encode(), hash_pw.encode())
