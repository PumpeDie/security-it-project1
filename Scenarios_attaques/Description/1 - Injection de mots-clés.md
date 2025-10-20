# Attaque 1 : Injection de Mots-Clés Suspects

## Nom Commun
**Keyword Injection / Suspicious Pattern Injection**

## Explication
Cette attaque consiste à injecter des mots-clés suspects dans les URLs ou paramètres HTTP, notamment pour tester la réactivité des systèmes de détection (WAF, IDS/IPS). On insère volontairement des termes comme "attack", "hack", "exploit" dans les requêtes pour :
- Cartographier les systèmes de sécurité en place
- Identifier les règles de détection actives
- Tester les faux positifs et la sensibilité du WAF
- Préparer une attaque plus sophistiquée en comprenant les défenses

C'est souvent une phase de reconnaissance avant une attaque réelle.

## Popularité
⭐⭐ **Faible à Moyenne**

Peu utilisée comme attaque en soi, mais courante en phase de **reconnaissance** et de **fingerprinting** des systèmes de sécurité. Les attaquants expérimentés utilisent cette technique pour comprendre comment le système réagit avant de lancer des attaques plus élaborées.

## Commandes lancées

```bash
# Test 1 : Injection du mot-clé "attack"
curl http://127.0.0.1:8080/test?keyword=attack

# Test 2 : Injection du mot-clé "attacker"
curl http://127.0.0.1:8080/page?user=attacker
```

## Règles Suricata déclenchées

```
# SID 1000001 - Détection du mot "attack"
alert http any any -> any any (msg:"WEB_ATTACK_Keyword detected in URI: attack"; flow:to_server; content:"attack"; http_uri; nocase; classtype:policy-violation; sid:1000001; rev:1;)

# SID 1000002 - Détection du mot "attacker"
alert http any any -> any any (msg:"WEB_ATTACK_Keyword detected in URI: attacker"; flow:to_server; content:"attacker"; http_uri; nocase; classtype:policy-violation; sid:1000002; rev:1;)
```

### Fonctionnement de la détection
- `content:"attack"` : Recherche la chaîne "attack" dans l'URI
- `http_uri` : Spécifie de chercher uniquement dans l'URI HTTP
- `nocase` : Recherche insensible à la casse (ATTACK, attack, AtTaCk)
- `flow:to_server` : Surveille les requêtes client vers serveur

## Logs générés par l'attaque

```json
2025-10-19T23:19:15.804534+0000 | SID 1000001 | WEB_ATTACK_Keyword detected in URI: attack | URL: /test?keyword=attack
2025-10-19T23:19:16.823185+0000 | SID 1000002 | WEB_ATTACK_Keyword detected in URI: attacker | URL: /page?user=attacker
```

### Format complet (EVE JSON)

```json
{
  "timestamp": "2025-10-19T23:19:15.804534+0000",
  "flow_id": 922173348620701,
  "event_type": "alert",
  "src_ip": "127.0.0.1",
  "dest_ip": "127.0.0.1",
  "dest_port": 8080,
  "proto": "TCP",
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 1000001,
    "signature": "WEB_ATTACK_Keyword detected in URI: attack",
    "category": "policy-violation",
    "severity": 3
  },
  "http": {
    "hostname": "127.0.0.1",
    "url": "/test?keyword=attack",
    "http_method": "GET"
  }
}
```
