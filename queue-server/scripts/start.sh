#!/bin/bash
set -e
systemctl daemon-reload
systemctl enable furn-queue
systemctl restart furn-queue
