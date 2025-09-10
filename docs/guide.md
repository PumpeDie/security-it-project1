# Guide d'Installation - Système de Surveillance de Sécurité

## Prérequis

- Docker et Docker Compose installés
- Au moins 2GB de RAM disponible
- Ports 8080, 5601, 9200 libres

## Configuration Détaillée des Composants

### Elasticsearch (Port 9200) - Base de Données des Logs

Elasticsearch stocke et indexe tous les logs de sécurité pour permettre des recherches rapides et analyses.

**Fichier de configuration:** [`compose.yml`](../compose.yml) - section elasticsearch

```yaml
environment:
  - discovery.type=single-node      # Configure un nœud unique (pas de cluster)
  - xpack.security.enabled=false    # Désactive l'authentification pour simplifier les tests
  - ES_JAVA_OPTS=-Xms512m -Xmx512m  # Limite la mémoire Java à 512MB min/max
```

**Pourquoi ces paramètres :**
- **single-node** : Évite les erreurs de cluster dans un environnement de test
- **security disabled** : Permet l'accès direct sans authentification (uniquement pour développement)
- **Memory limits** : Évite qu'Elasticsearch consomme toute la RAM disponible

**Volume de données :**
```yaml
volumes:
  - es_data:/usr/share/elasticsearch/data  # Persiste les données entre redémarrages
```

### Kibana (Port 5601) - Interface de Visualisation

Kibana fournit l'interface web pour explorer les logs et créer des tableaux de bord de sécurité.

**Fichier de configuration:** [`compose.yml`](../compose.yml) - section kibana

```yaml
depends_on:
  - elasticsearch  # Démarre après Elasticsearch
```

**Configuration automatique :**
- Se connecte automatiquement à `http://elasticsearch:9200`
- Utilise la résolution DNS interne de Docker pour trouver Elasticsearch
- Hérite des paramètres de sécurité d'Elasticsearch (désactivée)

### Suricata (IDS) - Détection d'Intrusions

Suricata surveille le trafic réseau et génère des alertes de sécurité en JSON.

**Fichier de configuration Docker:** [`compose.yml`](../compose.yml) - section suricata

```yaml
network_mode: host                # Accède directement aux interfaces réseau de l'hôte
cap_add:
  - NET_ADMIN                     # Permissions nécessaires pour capturer les paquets
command: ["/usr/bin/suricata", "-c", "/etc/suricata/suricata.yaml", "-i", "lo", "-v"]
```

**Explication des paramètres :**
- **network_mode: host** : Permet à Suricata de voir le trafic réseau réel
- **NET_ADMIN** : Capacité système pour l'analyse de paquets
- **-i lo** : Surveille l'interface loopback (trafic localhost)
- **-v** : Mode verbose pour plus de logs de débogage

**Fichier de configuration Suricata:** [`src/config/suricata/suricata.yaml`](../src/config/suricata/suricata.yaml)

```yaml
# Définit quels réseaux sont considérés comme "internes"
vars:
  address-groups:
    HOME_NET: "192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"  # Réseaux privés RFC1918
    EXTERNAL_NET: "!$HOME_NET"                            # Tout le reste = externe

# Configure la sortie JSON pour l'intégration avec Elasticsearch
outputs:
  - eve-log:
      enabled: yes
      filename: /var/log/suricata/eve.json  # Fichier que syslog-ng va lire
      types:
        - alert    # Alertes de sécurité
        - http     # Requêtes HTTP détaillées
        - dns      # Requêtes DNS
        - tls      # Connexions SSL/TLS
```

**Volumes partagés :**
```yaml
volumes:
  - ./src/config/suricata:/etc/suricata  # Configuration modifiable
  - suricata_logs:/var/log/suricata      # Logs partagés avec syslog-ng
```

### syslog-ng (Collecteur) - Agrégation des Logs

syslog-ng collecte les logs de Suricata et Nginx, puis les envoie vers Elasticsearch.

**Fichier de configuration:** [`src/config/syslog-ng/syslog-ng.conf`](../src/config/syslog-ng/syslog-ng.conf)

```conf
# Source : Logs JSON de Suricata
source s_suricata {
  file("/var/log/suricata/eve.json"    # Fichier généré par Suricata
    follow-freq(1)                     # Vérifie les nouvelles données chaque seconde
    flags(no-parse)                    # Ne parse pas le JSON (garde le format original)
  );
};

# Source : Logs d'accès Nginx
source s_nginx {
  file("/var/log/nginx/access.log"     # Logs HTTP du serveur web
    follow-freq(1)                     # Surveillance continue
    flags(no-parse)                    # Garde le format original
  );
};

# Destination : Sortie console pour debugging
destination d_console {
  file("/proc/1/fd/1");                # stdout du conteneur Docker
};
```

**Explication du flux de données :**
1. **Suricata** → écrit dans `/var/log/suricata/eve.json`
2. **Nginx** → écrit dans `/var/log/nginx/access.log`  
3. **syslog-ng** → lit ces fichiers et affiche sur console

### Nginx (Port 8080) - Serveur Web de Test

Nginx sert une page web simple et génère des logs d'accès pour alimenter le système de surveillance.

**Fichier de configuration:** [`src/config/nginx/nginx.conf`](../src/config/nginx/nginx.conf)

```conf
# Format des logs d'accès personnalisé pour l'analyse de sécurité
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';

access_log /var/log/nginx/access.log main;  # Utilise le format personnalisé
error_log /var/log/nginx/error.log;         # Logs d'erreur séparés
```

**Pourquoi ce format de logs :**
- **$remote_addr** : IP de l'attaquant potentiel
- **$request** : Requête complète (méthode + URL + paramètres)
- **$status** : Code de réponse (404 = tentative d'accès non autorisé)
- **$http_user_agent** : Détection d'outils d'attaque automatisés

**Page web de test:** [`src/web/index.html`](../src/web/index.html)
```html
<!-- Liens qui génèrent différents types de trafic pour les tests -->
<a href="/admin">Admin Panel</a>          <!-- 404 = tentative accès admin -->
<a href="/api/users">API Endpoint</a>      <!-- Énumération d'API -->
<a href="/search?q=test">Search Test</a>   <!-- Paramètres GET suspects -->
```

## Tests de Fonctionnement

### 1. Vérifier l'état des services
```bash
# Elasticsearch accessible et en bonne santé
curl http://localhost:9200/_cluster/health

# Kibana démarré (peut prendre 1-2 minutes)
curl http://localhost:5601/api/status

# Serveur web répond
curl http://localhost:8080/
```

### 2. Générer du trafic de test pour les 5 scénarios
```bash
# Trafic normal (200 OK)
curl http://localhost:8080/

# Tentatives d'accès admin (404 Not Found)
curl http://localhost:8080/admin
curl http://localhost:8080/login

# Requêtes suspectes avec paramètres
curl "http://localhost:8080/search?q=test"
curl "http://localhost:8080/api/users?id=1"
```

### 3. Vérifier la collecte des logs
```bash
# Logs de Suricata (doit montrer les requêtes HTTP)
docker compose logs suricata

# syslog-ng doit afficher les logs collectés
docker compose logs syslog-ng

# Vérifier les fichiers de logs générés
docker compose exec suricata ls -la /var/log/suricata/
docker compose exec nginx ls -la /var/log/nginx/
```

## Accès aux Interfaces

- **Application web de test:** http://localhost:8080
- **Kibana (tableaux de bord):** http://localhost:5601  
- **Elasticsearch (API):** http://localhost:9200

## Architecture des Volumes Docker

```yaml
volumes:
  es_data: local           # Données Elasticsearch persistées
  suricata_logs: local     # Logs Suricata partagés avec syslog-ng
  nginx_logs: local        # Logs Nginx partagés avec syslog-ng
```

Cette architecture permet aux services de partager des données tout en maintenant l'isolation des conteneurs.