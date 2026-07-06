#!/bin/bash
# CodeDeploy ValidateService — actuator 헬스가 UP 될 때까지 대기
set -e
for i in $(seq 1 30); do
  if curl -fs http://localhost:8080/actuator/health | grep -q '"status":"UP"'; then
    echo "backend healthy"
    exit 0
  fi
  sleep 5
done
echo "backend health check failed"
exit 1
