#!/bin/bash
set -e
for i in $(seq 1 24); do
  if curl -fs http://localhost:8081/actuator/health | grep -q '"status":"UP"'; then
    echo "queue healthy"; exit 0
  fi
  sleep 5
done
echo "queue health check failed"; exit 1
