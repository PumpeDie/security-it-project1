#!/bin/bash

# Test des règles Suricata
TARGET="http://127.0.0.1:8080"

echo "=== Tests Suricata ==="
echo ""

# Scenario 1 - Mots-clés 
echo "[1] Mots-clés"
echo "  -> curl $TARGET/test?keyword=attack"
curl -s "$TARGET/test?keyword=attack" > /dev/null
sleep 1
echo "  -> curl $TARGET/page?user=attacker"
curl -s "$TARGET/page?user=attacker" > /dev/null
sleep 1

# Scenario 2 - SQL injection
echo "[2] SQL Injection"
echo "  -> curl $TARGET/user?id=1 OR 1=1"
curl -s "$TARGET/user?id=1 OR 1=1" > /dev/null
sleep 1
echo "  -> curl $TARGET/search?q=admin'"
curl -s "$TARGET/search?q=admin'" > /dev/null
sleep 1

# Scenario 3 - Path Traversal
echo "[3] Path Traversal"
echo "  -> curl $TARGET/../../../etc/passwd"
curl -s "$TARGET/../../../etc/passwd" > /dev/null
sleep 1
echo "  -> curl $TARGET/files?path=../../secret.txt"
curl -s "$TARGET/files?path=../../secret.txt" > /dev/null
sleep 1

# Scenario 4 - XSS
echo "[4] XSS"
echo "  -> curl $TARGET/comment?text=<script>alert('xss')</script>"
curl -s "$TARGET/comment?text=<script>alert('xss')</script>" > /dev/null
sleep 1

# Scenario 5 - Brute Force
echo "[5] Brute Force"
for i in {1..6}; do
    echo "  -> tentative $i/6"
    curl -s "$TARGET/login?user=admin&pass=test$i" > /dev/null
    sleep 0.3
done

echo ""
echo "Done. Check logs:"
echo "docker exec suricata tail /var/log/suricata/eve.json"