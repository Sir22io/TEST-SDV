# Toolbox Cyber - Projet Mastère ESI M1 / Sup de Vinci

## Description
Automatisation de tests d’intrusion (scan Nmap, reporting, RBAC, interface web).

## Installation rapide

### Backend
- Cloner le repo, aller dans `backend/`
- Installer les dépendances : `pip install -r requirements.txt`
- Lancer le serveur : `uvicorn main:app --reload`

### Frontend
- Aller dans `frontend/`
- Installer les dépendances : `npm install`
- Lancer : `npm start` (serveur local)

### Docker
- Lancer le tout en un : `docker-compose up --build`

## Fonctionnalités principales
- Authentification JWT sécurisée (register/login)
- Scan Nmap automatisé
- Génération de rapports PDF
- Interface utilisateur simple

## Configuration, sécurité, RGPD…
*(Détail à compléter selon besoin et livrable final)*
