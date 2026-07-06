#!/bin/bash
# CodeDeploy ValidateService — nginx 헬스 확인
set -e
for i in $(seq 1 12); do
  if curl -fs http://localhost:8080/health | grep -q ok; then
    echo "frontend healthy"
    exit 0
  fi
  sleep 5
done
echo "frontend health check failed"
exit 1
