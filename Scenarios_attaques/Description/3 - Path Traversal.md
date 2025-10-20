# Attaque 3 : Path Traversal

## Nom
**Path Traversal / Directory Traversal / Dot-Dot-Slash Attack**

## Explication
Le Path Traversal est une technique d'attaque qui permet de naviguer dans l'arborescence du système de fichiers pour accéder à des fichiers et répertoires situés en dehors du répertoire racine de l'application web. En utilisant la séquence `../` (remontée de répertoire), l'attaquant peut "sortir" du dossier autorisé et accéder à des fichiers sensibles du système.

Objectifs typiques de l'attaquant :
- Lire `/etc/passwd` pour énumérer les utilisateurs système
- Accéder à `/etc/shadow` pour tenter de cracker les mots de passe
- Lire les fichiers de configuration (credentials, clés API)
- Accéder au code source de l'application
- Consulter les logs pour trouver des informations sensibles

La séquence `../` permet de "remonter" d'un niveau dans l'arborescence. En répétant cette séquence, l'attaquant peut atteindre la racine du système puis naviguer vers n'importe quel fichier accessible.

## Popularité
⭐⭐⭐⭐ **Élevée**

Très courante et efficace contre les applications mal sécurisées. Elle figure dans le Top 10 OWASP (A01:2021 - Broken Access Control). De nombreux CMS, frameworks et applications custom sont vulnérables à cette attaque qui reste simple à exécuter mais dévastatrice.

## Commandes lancées

```bash
# Test 1 : Tentative d'accès à /etc/passwd (liste des utilisateurs Linux)
curl http://127.0.0.1:8080/../../../etc/passwd

# Test 2 : Accès à un fichier secret via paramètre
curl http://127.0.0.1:8080/files?path=../../secret.txt
```

## Règle Suricata déclenchée

```
# SID 1000005 - Détection de traversée de répertoire
alert http any any -> any any (msg:"WEB_ATTACK_Path Traversal attempt - parent directory access"; flow:to_server; content:"../"; http_uri; classtype:attempted-admin; sid:1000005; rev:1;)
```

### Fonctionnement de la détection
- `content:"../"` : Détecte la séquence de remontée de répertoire
- `http_uri` : Recherche dans l'URI uniquement
- `classtype:attempted-admin` : Catégorise comme tentative d'accès administrateur
- La règle détecte toutes les variations contenant `../`

## Logs générés par l'attaque

```json
2025-10-19T23:19:19.200000+0000 | SID 1000005 | WEB_ATTACK_Path Traversal attempt - parent directory access | URL: /../../../etc/passwd
2025-10-19T23:19:19.800000+0000 | SID 1000005 | WEB_ATTACK_Path Traversal attempt - parent directory access | URL: /files?path=../../secret.txt
```

### Format complet (EVE JSON)

```json
{
  "timestamp": "2025-10-19T23:19:19.200000+0000",
  "event_type": "alert",
  "src_ip": "127.0.0.1",
  "dest_ip": "127.0.0.1",
  "dest_port": 8080,
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 1000005,
    "signature": "WEB_ATTACK_Path Traversal attempt - parent directory access",
    "category": "attempted-admin",
    "severity": 2
  },
  "http": {
    "hostname": "127.0.0.1",
    "url": "/../../../etc/passwd",
    "http_method": "GET"
  }
}
```
