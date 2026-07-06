#!/bin/bash
# CodeDeploy AfterInstall — 런타임 env(same-origin) 재생성 + nginx 리로드
# (nginx conf /etc/nginx/conf.d/furn.conf 는 user-data 가 생성해 유지됨)
set -e
cat > /usr/share/nginx/html/env-config.js <<'EOF'
window.ENV = { API_BASE_URL: "", STATIC_ASSETS_URL: "" };
EOF
nginx -t
systemctl reload nginx
