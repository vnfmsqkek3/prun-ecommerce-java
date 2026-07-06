#!/bin/sh
set -e

# Render nginx config, substituting only ${BACKEND_URL} (leave nginx's own $vars intact).
# BACKEND_URL is the internal backend ALB, e.g. http://internal-furn-prod-back-alb-....elb.amazonaws.com
export BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"
envsubst '${BACKEND_URL}' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf

# Inject runtime environment variables into the frontend SPA.
# Empty API_BASE_URL => same-origin, so the browser calls nginx which proxies /api to the backend ALB.
cat > /usr/share/nginx/html/env-config.js <<EOF
window.ENV = {
  API_BASE_URL: "${API_BASE_URL:-}",
  STATIC_ASSETS_URL: "${STATIC_ASSETS_URL:-}"
};
EOF
exec "$@"
