# Tests des Règles Suricata

Ce guide explique comment lancer les attaques simulées et visualiser les alertes générées par Suricata.

## Prérequis

- Docker et Docker Compose installés
- `jq` installé pour formatter les logs JSON

```bash
# Installation de jq (si nécessaire)
sudo apt install jq  # Ubuntu/Debian
```

## Démarrage de la stack

```bash
# Démarrer tous les services
docker compose up -d

# Vérifier que les services sont en cours d'exécution
docker compose ps
```

## Lancer les attaques

Le script `run_attacks.sh` simule 5 scénarios d'attaque :

```bash
# Rendre le script exécutable (si nécessaire)
chmod +x run_attacks.sh

# Lancer les tests
./run_attacks.sh
```

### Scénarios testés

1. [Mots-clés](Description/1%20-%20Injection%20de%20mots-clés.md) : Détection de "attack" et "attacker" dans l'URI
2. **SQL Injection** : Tentatives d'injection SQL avec OR 1=1 et quotes
3. **Path Traversal** : Accès aux répertoires parents avec ../
4. **XSS** : Injection de balises `<script>`
5. **Brute Force** : Tentatives multiples de connexion sur /login

## Visualisation des alertes

### Commande complète (recommandée)

Affiche le timestamp, le SID, le message d'alerte et l'URL ciblée :

```bash
sudo docker exec suricata grep '"event_type":"alert"' /var/log/suricata/eve.json | jq -r '"\(.timestamp) | SID \(.alert.signature_id) | \(.alert.signature) | URL: \(.http.url)"'
```

### Comptage des alertes par SID

```bash
sudo docker exec suricata grep '"event_type":"alert"' /var/log/suricata/eve.json | jq -r '.alert.signature_id' | sort | uniq -c
```

### Résumé groupé des alertes

```bash
sudo docker exec suricata grep '"event_type":"alert"' /var/log/suricata/eve.json | jq -r '"[\(.alert.signature_id)] \(.alert.signature)"' | sort | uniq -c
```

### Voir toutes les alertes en temps réel

Dans un terminal séparé, avant de lancer les attaques :

```bash
sudo docker exec suricata tail -f /var/log/suricata/eve.json | grep '"event_type":"alert"' | jq .
```

## Vider les logs

Pour repartir à zéro entre deux tests :

```bash
sudo docker exec suricata bash -c "> /var/log/suricata/eve.json"
```

## Workflow complet de test

```bash
# 1. Vider les anciens logs
sudo docker exec suricata bash -c "> /var/log/suricata/eve.json"

# 2. Lancer les attaques
./run_attacks.sh

# 3. Attendre que Suricata traite les paquets
sleep 3

# 4. Voir les alertes détaillées
sudo docker exec suricata grep '"event_type":"alert"' /var/log/suricata/eve.json | jq -r '"\(.timestamp) | SID \(.alert.signature_id) | \(.alert.signature) | URL: \(.http.url)"'

# 5. Comptage par règle
sudo docker exec suricata grep '"event_type":"alert"' /var/log/suricata/eve.json | jq -r '.alert.signature_id' | sort | uniq -c
```

## Dépannage

### Les règles ne se chargent pas

```bash
# Vérifier les erreurs de parsing
docker logs suricata 2>&1 | grep -i error

# Redémarrer Suricata
docker restart suricata
```

### Aucune alerte générée

```bash
# Vérifier que les requêtes HTTP sont capturées
sudo docker exec suricata grep '"event_type":"http"' /var/log/suricata/eve.json | jq -r '.http.url' | tail -20

# Vérifier que les règles sont chargées
docker exec suricata cat /etc/suricata/rules/local.rules
```

## Arrêt de la stack

```bash
docker compose down
```
