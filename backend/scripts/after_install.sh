#!/bin/bash
# CodeDeploy AfterInstall — jar 소유권 정리
set -e
chown ec2-user:ec2-user /opt/furn/app.jar
