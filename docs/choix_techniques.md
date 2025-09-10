# Justifications des Choix Techniques

## Docker vs Machines Virtuelles

**Choix retenu :** Docker avec Docker Compose

**Avantages :**
- **Portabilité :** Fonctionne sur Windows, Linux et macOS
- **Isolation complète :** Chaque service dans son propre conteneur isolé
- **Déploiement rapide :** `docker compose up -d` lance tout
- **Reproductibilité :** Environnement identique pour toute l'équipe
- **Ressources optimisées :** ~2GB RAM total vs ~4GB+ avec des VMs

**Comparaison :**
| Critère | Docker | VMs |
|---------|--------|-----|
| Démarrage | 30 sec | 2 min |
| Configuration | 1 fichier | Manuelle |
| Maintenance | Auto | Manuelle |

## Suricata vs Snort

**Choix retenu :** Suricata

**Avantages :**
- **Multi-threading natif :** Utilise tous les cœurs CPU
- **JSON natif :** Intégration directe avec Elasticsearch
- **Configuration YAML :** Plus simple que Snort
- **Images Docker officielles :** Prêt à l'emploi

## syslog-ng vs Logstash

**Choix retenu :** syslog-ng

**Avantages :**
- **Configuration claire :** Syntax simple et lisible
- **Performance :** Architecture event-driven
- **Parsing JSON natif :** Compatible avec les logs Suricata
- **Léger :** Moins de ressources que Logstash

## Elasticsearch + Kibana vs ELK Stack

**Choix retenu :** Elasticsearch + Kibana 9.0.7
> Pas de Logstash dans notre architecture - syslog-ng assure la collecte et le transport des logs.

**Elasticsearch** : Base de données pour stocker et indexer les logs de sécurité
**Kibana** : Interface web pour visualiser les logs et créer des dashboards

**Avantages :**
- **Écosystème intégré :** Versions compatibles
- **Standard industrie :** Largement utilisé en entreprise
- **Documentation complète :** Facile à apprendre
- **Visualisations avancées :** Dashboards pour sécurité

## Nginx vs Apache

**Choix retenu :** Nginx Alpine

**Avantages :**
- **Léger :** 23MB vs 180MB
- **Logs standards :** Compatible avec nos outils
- **Configuration simple :** Un seul fichier
- **Génère du trafic de test :** Pour nos 5 scénarios

## Conclusion

Architecture simple, performante et reproductible pour l'apprentissage des concepts de sécurité réseau.