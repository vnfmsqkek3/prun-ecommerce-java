#!/bin/bash
# CodeDeploy ApplicationStart — systemd 서비스 기동
# systemd 유닛/env(/etc/furn-backend.env)은 user-data 가 이미 생성해 둠.
set -e
systemctl daemon-reload
systemctl enable furn-backend
systemctl restart furn-backend
