#!/bin/bash
# CodeDeploy BeforeInstall — 설치 대상 jar 선제거.
# seed 부트스트랩(userdata) 또는 이전 리비전이 남긴 /opt/furn-queue/app.jar 와
# appspec files 복사가 "file already exists" 로 충돌하는 것을 방지.
set -e
rm -f /opt/furn-queue/app.jar
