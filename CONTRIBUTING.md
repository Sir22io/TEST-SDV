# 🤝 Guide de Contribution

Merci de votre intérêt pour contribuer à CyberToolbox Pro !

## 🔄 Processus de Contribution

1. **Fork** le repository
2. **Clone** votre fork localement
3. **Créer** une branche pour votre feature (`git checkout -b feature/amazing-feature`)
4. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
5. **Push** vers votre fork (`git push origin feature/amazing-feature`)
6. **Ouvrir** une Pull Request

## 📝 Standards de Code

### Python (Backend)
- **Formatage :** Black avec ligne de 88 caractères
- **Import :** isort pour l'organisation des imports
- **Linting :** Flake8 avec configuration du projet
- **Type hints :** Utilisation obligatoire des annotations de type
- **Docstrings :** Format Google docstring

```python
def scan_target(target: str, scan_type: str = "syn") -> Dict[str, Any]:
    """
    Effectue un scan Nmap sur une cible donnée.
    
    Args:
        target: Adresse IP ou nom de domaine à scanner
        scan_type: Type de scan (syn, tcp, udp, ping)
    
    Returns:
        Dictionnaire contenant les résultats du scan
        
    Raises:
        ScanException: Si le scan échoue
    """
    pass
