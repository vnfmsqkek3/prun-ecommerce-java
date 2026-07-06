#!/bin/bash
# CodeDeploy BeforeInstall — 기존 웹루트 정리 (env-config.js 포함 전체)
set -e
find /usr/share/nginx/html -mindepth 1 -delete 2>/dev/null || true
