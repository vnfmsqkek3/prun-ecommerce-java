#!/bin/bash
# CodeDeploy ApplicationStop — 기존 서비스 정지 (없으면 무시)
systemctl stop furn-backend 2>/dev/null || true
