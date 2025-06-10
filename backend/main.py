from fastapi import FastAPI, Depends, HTTPException, status, Request
from auth.auth import authenticate_user, create_access_token, get_current_user
from auth.models import init_db, add_user, get_user
from modules.nmap_runner import run_nmap
from reporting.report_gen import generate_pdf
from pydantic import BaseModel

app = FastAPI()

init_db()

class AuthReq(BaseModel):
    username: str
    password: str

class NmapReq(BaseModel):
    target: str

@app.post("/api/auth/token")
def login(auth: AuthReq):
    user = authenticate_user(auth.username, auth.password)
    if not user:
        raise HTTPException(status_code=400, detail="Identifiants invalides")
    token = create_access_token({"sub": user["username"], "role": user["role"]})
    return {"access_token": token, "token_type": "bearer"}

@app.post("/api/auth/register")
def register(auth: AuthReq):
    from auth.utils import hash_password
    if not auth.username or not auth.password:
        raise HTTPException(status_code=400, detail="Champs vides")
    if get_user(auth.username):
        raise HTTPException(status_code=400, detail="Utilisateur déjà existant")
    add_user(auth.username, hash_password(auth.password))
    return {"message": "Utilisateur créé"}

@app.post("/api/scan/nmap")
def scan_nmap(req: NmapReq, user=Depends(get_current_user)):
    output, date = run_nmap(req.target)
    # Génération PDF
    pdf_filename = generate_pdf({"target": req.target, "date": date, "result": output})
    return {"output": output, "pdf_report": pdf_filename, "date": date}
