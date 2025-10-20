# Attaque 4 : Cross-Site Scripting (XSS)

## Nom
**Cross-Site Scripting (XSS)**

## Explication
Le Cross-Site Scripting est une technique d'injection de code JavaScript malveillant dans une application web. L'attaquant insère du code qui sera exécuté dans le navigateur des victimes qui consultent la page compromise. Le navigateur, ne pouvant pas distinguer le script malveillant du code légitime, l'exécute avec les mêmes privilèges.

Objectifs de l'attaquant :
- **Voler des sessions** : Capturer les cookies de session pour usurper l'identité de la victime
- **Phishing** : Afficher de fausses pages de connexion pour voler des identifiants
- **Redirection malveillante** : Rediriger vers des sites de phishing ou de malware
- **Keylogging** : Enregistrer les frappes clavier de la victime
- **Défacement** : Modifier l'apparence du site
- **Distribution de malware** : Faire télécharger des fichiers malveillants

Types d'XSS :
- **Reflected XSS** : Le payload est dans l'URL et immédiatement renvoyé par le serveur
- **Stored XSS** : Le payload est stocké en base de données (commentaires, profils)
- **DOM-based XSS** : L'attaque exploite le DOM côté client

## Popularité
⭐⭐⭐⭐⭐ **Très élevée**

XSS est l'une des vulnérabilités web les plus répandues et exploitées. Elle touche des sites de toutes tailles, des blogs personnels aux grandes plateformes. Figure dans le Top 3 du OWASP Top 10. Des millions de sites sont vulnérables, et l'exploitation est relativement simple.

## Commandes lancées

```bash
# Test 1 : XSS simple avec alert (preuve de concept)
curl "http://127.0.0.1:8080/comment?text=<script>alert('xss')</script>"

# Test 2 : XSS avec redirection vers un site malveillant
curl "http://127.0.0.1:8080/search?q=<script>document.location='http://evil.com'</script>"
```

## Règle Suricata déclenchée

```
# SID 1000009 - Détection de balise <script>
alert http any any -> any any (msg:"WEB_ATTACK_XSS attempt - script tag in URI"; flow:to_server; content:"<script>"; http_uri; nocase; classtype:attempted-user; sid:1000009; rev:1;)
```

### Fonctionnement de la détection
- `content:"<script>"` : Détecte la balise script dans l'URI
- `nocase` : Insensible à la casse (<SCRIPT>, <ScRiPt>, etc.)
- `http_uri` : Recherche uniquement dans l'URI HTTP
- `classtype:attempted-user` : Tentative d'exploitation utilisateur

## Logs générés par l'attaque

```json
2025-10-19T23:19:20.300000+0000 | SID 1000009 | WEB_ATTACK_XSS attempt - script tag in URI | URL: /comment?text=<script>alert('xss')</script>
2025-10-19T23:19:20.900000+0000 | SID 1000009 | WEB_ATTACK_XSS attempt - script tag in URI | URL: /search?q=<script>document.location='http://evil.com'</script>
```

### Format complet (EVE JSON)

```json
{
  "timestamp": "2025-10-19T23:19:20.300000+0000",
  "event_type": "alert",
  "src_ip": "127.0.0.1",
  "dest_ip": "127.0.0.1",
  "dest_port": 8080,
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 1000009,
    "signature": "WEB_ATTACK_XSS attempt - script tag in URI",
    "category": "attempted-user",
    "severity": 2
  },
  "http": {
    "hostname": "127.0.0.1",
    "url": "/comment?text=<script>alert('xss')</script>",
    "http_method": "GET"
  }
}
```
