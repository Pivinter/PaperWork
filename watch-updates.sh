#!/bin/bash


INTERVAL=60
COMPOSE_FILE="docker-compose.prod.yml"

echo "Auto-Update Monitor Started"
echo "Checking every ${INTERVAL} seconds"
echo "Press Ctrl+C to stop"
echo ""

while true; do
    echo "[$(date '+%H:%M:%S')] Checking for updates..."
    
    docker compose -f ${COMPOSE_FILE} pull --quiet
    
    if docker compose -f ${COMPOSE_FILE} up -d --no-build 2>&1 | grep -q "Recreated\|Started"; then
        echo "[$(date '+%H:%M:%S')] Updates applied! Containers restarted."
        sleep 5
        docker compose -f ${COMPOSE_FILE} ps
    else
        echo "[$(date '+%H:%M:%S')] No updates available"
    fi
    
    echo ""
    sleep ${INTERVAL}
done
