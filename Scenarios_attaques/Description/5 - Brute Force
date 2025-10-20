# Attaque 5 : Brute Force

## Nom Commun
**Brute Force Attack / Credential Stuffing**

## Explication
Une attaque par force brute consiste à deviner des identifiants de connexion en testant systématiquement et automatiquement un grand nombre de combinaisons username/password. L'attaquant utilise des scripts ou outils automatisés pour envoyer des centaines, voire des milliers de tentatives de connexion par minute.

Stratégies d'attaque :
- **Brute Force pur** : Teste toutes les combinaisons possibles (a, b, c... aa, ab, ac...)
- **Dictionary Attack** : Utilise des listes de mots de passe courants (123456, password, admin...)
- **Credential Stuffing** : Réutilise des credentials volés lors de fuites de données d'autres sites
- **Password Spraying** : Teste quelques mots de passe communs sur de nombreux comptes (évite le rate limiting par compte)

Outils populaires utilisés par les attaquants :
- Hydra, Medusa, Burp Suite Intruder, OWASP ZAP, scripts Python custom

L'attaquant compte sur :
- L'absence de rate limiting
- Des mots de passe faibles
- Pas de CAPTCHA
- Pas de blocage après X tentatives échouées

## Popularité
⭐⭐⭐⭐⭐ **Très élevée**

Les attaques par force brute représentent une part massive du trafic malveillant sur Internet. Chaque serveur SSH, RDP, ou formulaire de connexion web reçoit des milliers de tentatives quotidiennes. C'est l'une des méthodes les plus anciennes mais toujours très efficace contre les systèmes mal protégés.

## Commandes lancées

```bash
# Simulation de 6 tentatives de connexion rapides (0.3s d'intervalle)
# Dans une vraie attaque, ce serait des centaines de tentatives/seconde

curl "http://127.0.0.1:8080/login?user=admin&pass=test1"
sleep 0.3
curl "http://127.0.0.1:8080/login?user=admin&pass=test2"
sleep 0.3
curl "http://127.0.0.1:8080/login?user=admin&pass=test3"
sleep 0.3
curl "http://127.0.0.1:8080/login?user=admin&pass=test4"
sleep 0.3
curl "http://127.0.0.1:8080/login?user=admin&pass=test5"
sleep 0.3
curl "http://127.0.0.1:8080/login?user=admin&pass=test6"
```

## Règle Suricata déclenchée

```
# SID 1000011 - Détection de brute force par threshold
alert http any any -> any any (msg:"WEB_ATTACK_Brute Force Login attempt (Threshold Alert)"; flow:to_server; content:"/login"; http_uri; threshold: type limit, track by_src, count 5, seconds 60; classtype:attempted-dos; sid:1000011; rev:1;)
```

### Fonctionnement de la détection
- `content:"/login"` : Surveille les requêtes vers l'endpoint de connexion
- `threshold: type limit, track by_src, count 5, seconds 60` :
  - **type limit** : Limite le nombre d'alertes générées (évite le spam)
  - **track by_src** : Compte les requêtes par adresse IP source
  - **count 5** : Déclenche l'alerte après 5 tentatives
  - **seconds 60** : Dans une fenêtre de 60 secondes
- `classtype:attempted-dos` : Catégorisé comme tentative de déni de service

## Logs générés par l'attaque

```json
2025-10-19T23:19:21.148893+0000 | SID 1000011 | WEB_ATTACK_Brute Force Login attempt (Threshold Alert) | URL: /login?user=admin&pass=test4
2025-10-19T23:19:21.465781+0000 | SID 1000011 | WEB_ATTACK_Brute Force Login attempt (Threshold Alert) | URL: /login?user=admin&pass=test5
2025-10-19T23:19:21.832311+0000 | SID 1000011 | WEB_ATTACK_Brute Force Login attempt (Threshold Alert) | URL: /login?user=admin&pass=test6
```

**Note** : Les alertes commencent à partir de la 4ème requête car le threshold est configuré sur 5 (les 4 premières sont comptées, la 5ème déclenche).

### Format complet (EVE JSON)

```json
{
  "timestamp": "2025-10-19T23:19:21.148893+0000",
  "event_type": "alert",
  "src_ip": "127.0.0.1",
  "dest_ip": "127.0.0.1",
  "dest_port": 8080,
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 1000011,
    "
