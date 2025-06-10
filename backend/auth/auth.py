from datetime import datetime, timedelta
from jose import jwt
from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from .models import get_user
from .utils import verify_password

SECRET_KEY = "votre_cle_secrete_super_longue"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 120

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

def authenticate_user(username: str, password: str):
    user = get_user(username)
    if user and verify_password(password, user["password_hash"]):
        return user
    return None

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(token: str = Depends(oauth2_scheme)):
    from jose import JWTError
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Token invalid")
        user = get_user(username)
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    except JWTError:
        raise HTTPException(status_code=401, detail="Token invalid")
