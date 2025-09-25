#!/bin/bash
NAME=sk199
IMAGE_NAME="myfirst-api-server"
VERSION="2.0.0-NEW"

CPU_PLATFORM=amd64

# Docker 이미지 빌드
docker build \
  --tag ${NAME}-${IMAGE_NAME}:${VERSION} \
  --file Dockerfile \
  --platform linux/${CPU_PLATFORM} \
  ${IS_CACHE} .
