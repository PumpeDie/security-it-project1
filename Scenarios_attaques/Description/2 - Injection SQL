# Attaque 2 : Injection SQL

## Nom Commun
**SQL Injection (SQLi)**

## Explication
L'injection SQL est une technique d'attaque qui exploite les failles de sécurité dans les applications web en insérant du code SQL malveillant dans les paramètres de requête. L'attaquant manipule les requêtes SQL envoyées à la base de données pour :
- Contourner l'authentification (ex: `OR 1=1` rend toujours la condition vraie)
- Extraire des données sensibles (dump de tables)
- Modifier ou supprimer des données
- Obtenir un accès administrateur
- Exécuter des commandes système dans certains cas

Les vecteurs d'attaque courants :
- **OR 1=1** : Condition toujours vraie pour bypass l'authentification
- **Guillemets simples (')** : Ferme prématurément les chaînes SQL
- **Guillemets doubles (")** : Idem pour les requêtes utilisant des doubles quotes
- **UNION SELECT** : Extraction de données depuis d'autres tables
- **'; DROP TABLE--** : Injection destructive

## Popularité
⭐⭐⭐⭐⭐ **Très élevée**

L'injection SQL reste l'une des attaques les plus critiques et exploitées. Elle figure au Top 3 du OWASP Top 10 depuis des années. Des milliers de sites sont compromis chaque année via SQLi, avec des conséquences désastreuses (vol de millions de comptes, défacement, ransomware).

## Commandes lancées

```bash
# Test 1 : Injection SQL avec OR 1=1 (bypass authentification)
curl "http://127.0.0.1:8080/user?id=1 OR 1=1"

# Test 2 : Injection avec guillemet simple (test de vulnérabilité)
curl "http://127.0.0.1:8080/search?q=admin'"

# Test 3 : Injection avec guillemet double
curl "http://127.0.0.1:8080/search?q=\"admin\""
```

## Règles Suricata déclenchées

```
# SID 1000003 - Détection de "OR 1=1"
alert http any any -> any any (msg:"WEB_ATTACK_SQL Injection attempt - OR 1=1"; flow:to_server; content:"|20|OR|20|1=1"; http_uri; nocase; classtype:attempted-user; sid:1000003; rev:1;)

# SID 1000004 - Détection des guillemets simples
alert http any any -> any any (msg:"WEB_ATTACK_SQL Injection attempt - Quotes"; flow:to_server; content:"'"; http_uri; classtype:attempted-user; sid:1000004; rev:1;)

# SID 1000006 - Détection des guillemets doubles
alert http any any -> any any (msg:"WEB_ATTACK_SQL Injection attempt - Double Quote"; flow:to_server; content:!"\"!"; http_uri; classtype:attempted-user; sid:1000006; rev:1;)
```

### Fonctionnement de la détection
- `content:"|20|OR|20|1=1"` : Détecte " OR 1=1" (0x20 = espace en hexa)
- `content:"'"` : Détecte les guillemets simples dans l'URI
- `classtype:attempted-user` : Catégorise comme tentative d'accès non autorisé

## Logs générés par l'attaque

```json
2025-10-19T23:19:17.500000+0000 | SID 1000003 | WEB_ATTACK_SQL Injection attempt - OR 1=1 | URL: /user?id=1 OR 1=1
2025-10-19T23:19:18.100000+0000 | SID 1000004 | WEB_ATTACK_SQL Injection attempt - Quotes | URL: /search?q=admin'
2025-10-19T23:19:18.600000+0000 | SID 1000006 | WEB_ATTACK_SQL Injection attempt - Double Quote | URL: /search?q="admin"
```

### Format complet (EVE JSON)

```json
{
  "timestamp": "2025-10-19T23:19:18.100000+0000",
  "event_type": "alert",
  "src_ip": "127.0.0.1",
  "dest_ip": "127.0.0.1",
  "dest_port": 8080,
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 1000004,
    "signature": "WEB_ATTACK_SQL Injection attempt - Quotes",
    "category": "attempted-user",
    "severity": 2
  },
  "http": {
    "hostname": "127.0.0.1",
    "url": "/search?q=admin'",
    "http_method": "GET"
  }
}
```
