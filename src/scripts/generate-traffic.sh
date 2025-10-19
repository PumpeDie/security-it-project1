#!/bin/bash
# Script to generate test traffic for security monitoring
# This script sends various HTTP requests to trigger Suricata rules and
# generate logs for analysis in Elasticsearch and Kibana

echo "Generating test traffic..."

# 1. Normal traffic - should not trigger alerts
curl -s http://localhost:8080/

# 2. Attempted access to admin area - will generate 404 errors
# This simulates an unauthorized access attempt
curl -s http://localhost:8080/admin
curl -s http://localhost:8080/login

# 3. Attack keyword detection - triggers Suricata rule (sid:1000001)
# The "attack" keyword is detected by our custom Suricata rule
curl -s "http://localhost:8080/search?q=attack"

# 4. SQL injection attempt - generates suspicious log entries
# Simulates an attacker trying to exploit a SQL injection vulnerability
curl -s "http://localhost:8080/api/users?id=1%20OR%201=1"

echo "Test traffic generated successfully!"