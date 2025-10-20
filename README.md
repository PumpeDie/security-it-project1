# Système de Surveillance de Sécurité

<div align="center">

![Statut](https://img.shields.io/badge/Statut-Terminé-success?style=for-the-badge)
<br/>
![Technologies](https://img.shields.io/badge/Technologies-Docker%20%7C%20Suricata%20%7C%20Elasticsearch%20%7C%20Kibana%20%7C%20syslog--ng%20%7C%20Nginx-blue?style=for-the-badge)

</div>

Solution de surveillance de sécurité utilisant Suricata IDS, Elasticsearch + Kibana, syslog-ng et Nginx pour la détection d'intrusions et l'analyse de logs.

## Architecture

- **Suricata** : Système de détection d'intrusions réseau (IDS)
- **Elasticsearch** : Stockage et indexation des logs
- **Kibana** : Interface de visualisation des logs et tableaux de bord
- **syslog-ng** : Collecte et transmission des logs. Va formater les logs de Suricata dans un format que va pouvoir exploiter ElasticSearch.
- **Nginx** : Serveur web pour générer du trafic de test

## Documentation

📖 **[Consignes du Projet](docs/consignes.md)** - Objectifs et barème détaillé

📋 **[Guide d'Installation et d'Utilisation](docs/guide.md)** - Instructions pour configurer et utiliser le système

💡 **[Justifications des Choix Techniques](docs/choix_techniques.md)** - Pourquoi Docker, Suricata, etc.

⚔️ **[Scénarios d'attaques](Scenarios_attaques/Launch.md)** - Guide de lancement et descriptions des attaques :
- [Injection de mots-clés](Scenarios_attaques/Description/1%20-%20Injection%20de%20mots-clés.md)
- [Injection SQL](Scenarios_attaques/Description/2%20-%20Injection%20SQL.md)
- [Path Traversal](Scenarios_attaques/Description/3%20-%20Path%20Traversal.md)
- [Cross-Site Scripting](Scenarios_attaques/Description/4%20-%20Cross-Site%20Scripting.md)
- [Brute Force](Scenarios_attaques/Description/5%20-%20Brute%20Force.md)

## Démarrage Rapide

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/PumpeDie/security-it-project1
   cd security-it-project1
   ```

2. **Démarrer tous les services**
   ```bash
   docker compose up -d
   ```

3. **Vérifier que les services fonctionnent**
   ```bash
   docker compose ps
   ```

4. **Accéder aux interfaces**
   - Application web : http://localhost:8080
   - Tableau de bord Kibana : http://localhost:5601
   - API Elasticsearch : http://localhost:9200

## Vue d'Ensemble des Services

```mermaid
graph TB
    subgraph "External Network"
        A[🌐 Attacker]
        U[👤 User]
    end
    
    subgraph "Docker Network"
        subgraph "Web Services"
            N[🌐 Nginx:8080<br/>Web Server]
        end
        
        subgraph "Monitoring & Detection"
            S[🛡️ Suricata IDS<br/>network_mode: host]
        end
        
        subgraph "Log Processing"
            SL[📊 syslog-ng<br/>Log Collector]
        end
        
        subgraph "Data Storage & Visualization"
            E[🔍 Elasticsearch:9200<br/>Log Database]
            K[📈 Kibana:5601<br/>Dashboard UI]
            SETUP[⚙️ Setup Service<br/>Dashboard Import]
        end
    end
    
    subgraph "Persistent Volumes"
        V1[(📁 nginx_logs)]
        V2[(📁 suricata_logs)]
        V3[(📁 es_data)]
    end
    
    %% Traffic flows
    U -->|HTTP requests| N
    A -->|Attack traffic| N
    
    %% Network monitoring
    S -.->|Monitor loopback<br/>interface 'lo'| N
    
    %% Log collection paths
    N -->|Write logs| V1
    S -->|Write EVE JSON| V2
    V1 -->|Read access logs| SL
    V2 -->|Read eve.json| SL
    SL -->|Forward parsed<br/>logs via HTTP| E
    
    %% Data storage & visualization
    E -->|Store indexed data| V3
    K -->|Query logs| E
    U -->|View dashboards| K
    
    %% Setup service initialization
    SETUP -->|Configure users<br/>& import dashboards| E
    SETUP -->|Import visualizations| K
    
    %% Styling
    classDef webService fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef security fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef logging fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef storage fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    classDef volume fill:#fafafa,stroke:#424242,stroke-width:2px
    classDef setup fill:#fff9c4,stroke:#f57f17,stroke-width:2px
    
    class N webService
    class S security
    class SL logging
    class E,K storage
    class V1,V2,V3 volume
    class SETUP setup
```

### Services Détaillés

### Elasticsearch

- **Port** : 9200
- **Objectif** : Stocke et indexe les logs de sécurité
- **Configuration** : Mode nœud unique avec sécurité désactivée pour la simplicité

Identifiant
:   `elastic`

Mot de passe
:   `MetNousCent`

### Kibana

- **Port** : 5601
- **Objectif** : Visualise les logs et fournit des tableaux de bord de sécurité
- **Dépendances** : Nécessite qu'Elasticsearch soit en fonctionnement

![Dashboard Overview](docs/screenshots/dashboard_overview.png)
*Vue d'ensemble des 5 scénarios d'attaque avec compteurs et graphiques*

![Discover Logs](docs/screenshots/discover_logs.png)
*Exploration des logs collectés par Suricata*

### Suricata

- **Objectif** : Surveille le trafic réseau et détecte les intrusions
- **Configuration** : Surveille l'interface loopback avec logging JSON activé
- **Sortie des logs** : `/var/log/suricata/eve.json`

### syslog-ng

- **Objectif** : Collecte les logs de Suricata et Nginx
- **Configuration** : Redirige les logs vers la sortie console
- **Sources** : Logs JSON Suricata, logs d'accès Nginx

### Nginx

- **Port** : 8080
- **Objectif** : Serveur web pour les tests et la génération de trafic HTTP
- **Logs** : Logs d'accès et d'erreur collectés par syslog-ng

## Fichiers de Configuration

```
.
├── compose.yml                    # Configuration des services Docker
├── run_attacks.sh                 # Script d'automatisation des attaques
└── src/                          # Sources et configurations
    ├── elasticsearch.yml         # Configuration Elasticsearch
    ├── config/                   # Configurations des services
    │   ├── kibana/              # Configuration Kibana
    │   │   └── export.ndjson    # Export des tableaux de bord
    │   ├── nginx/               # Configuration serveur web
    │   │   └── nginx.conf       # Configuration Nginx
    │   ├── suricata/           # Configuration IDS
    │   │   ├── classification.config  # Classification des alertes
    │   │   ├── reference.config      # Références des règles
    │   │   ├── suricata.yaml         # Configuration principale
    │   │   ├── threshold.config      # Seuils d'alertes
    │   │   ├── update.yaml           # Configuration des mises à jour
    │   │   └── rules/               # Règles de détection
    │   │       └── local.rules      # Règles personnalisées
    │   └── syslog-ng/           # Configuration collecteur de logs
    │       └── syslog-ng.conf   # Configuration syslog-ng
    └── web/                    # Application web de test
        └── index.html          # Page web simple pour les tests
```

## Arrêter le Système

```bash
docker compose down
```

Pour supprimer tous les volumes de données :

```bash
docker compose down -v
```

## Fonctionnalités de Sécurité

- Surveillance du trafic réseau avec Suricata
- Collecte centralisée des logs avec syslog-ng
- Analyse des logs en temps réel avec Elasticsearch
- Tableaux de bord de sécurité visuels avec Kibana
- Règles de détection et seuils configurables

## Analyse et conclusion

### Limites du projet

- **Limites de détection** : Suricata n'est sensible qu'aux menaces renseignés dans la configuration.

- **Contenairisation** : Le projet est dans plusieurs containers, cela est pratique pour travailler dessus depuis des environnements différents. Néanmoins, pour déployer notre solution, des ajustements de toutes les configs sont nécessaires.

- **Injection SQL** : la règle Suricata semble mal écrite, et de nouvelles alertes sont envoyées à intervalles réguliers, sans nouvelles attaques. **Création de faux positifs**

### Améliorations possibles

- Utilisation d'un autre IDS/IPS
- Automatisation de l'envoi d'alertes
- Utilisation d'autres règles Suricata

### Perspectives technologiques

- Intégration d'un SOAR pour répondre aux alertes

---

<div align="center">
<img src="docs/screenshots/IAg_limitee_compact.png" alt="Logo" width="150"/>
</div>

## 👥 Contributeurs

<div align="center">

<table>
<tr>
    <td align="center">
    <a href="https://github.com/PumpeDie">
        <img src="https://github.com/PumpeDie.png" width="100px;" alt="PumpeDie"/>
        <br />
        <sub><b>PumpeDie</b></sub>
        <br />
        <sub>Samuel PLET</sub>
    </a>
    </td>
    <td align="center">
    <a href="https://github.com/realnitsuj">
        <img src="https://github.com/realnitsuj.png" width="100px;" alt="realnitsuj"/>
        <br />
        <sub><b>realnitsuj</b></sub>
        <br />
        <sub>Justin BOSSARD</sub>
    </a>
    </td>
    <td align="center">
    <a href="https://github.com/paulm123456789">
        <img src="https://github.com/paulm123456789.png" width="100px;" alt="paulm123456789"/>
        <br />
        <sub><b>paulm123456789</b></sub>
        <br />
        <sub>Paul MATHE</sub>
    </a>
    </td>
    <td align="center">
    <a href="https://github.com/Go-GoZeppeli">
        <img src="https://github.com/Go-GoZeppeli.png" width="100px;" alt="Go-GoZeppeli"/>
        <br />
        <sub><b>Go-GoZeppeli</b></sub>
        <br />
        <sub>Mattéo GOUHIER</sub>
    </a>
    </td>
</tr>
</table>

</div>

---

<div align="center">
  <sub>Projet réalisé dans le cadre du cours de Sécurité Informatique - UQAC 2025</sub>
</div>
