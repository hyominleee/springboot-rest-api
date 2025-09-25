#!/bin/bash

set -xeu

NAME=sk199
HELM_NAME="myfirst-api-server"
VERSION="0.1.0"

HELM_PKG_NAME=${NAME}-${HELM_NAME}

DOCKER_REGISTRY="amdp-registry.skala-ai.com/skala25a"
DOCKER_REGISTRY_USER="robot\$skala25a"
DOCKER_REGISTRY_PASSWORD="1qB9cyusbNComZPHAdjNIFWinf52xaBJ"
DOCKER_CACHE="--no-cache"


# 1. Docker 레지스트리에 로그인 (옵션: 이 스크립트를 실행하기 전에 미리 로그인해두어도 됩니다)
echo ${DOCKER_REGISTRY_PASSWORD} | docker login ${DOCKER_REGISTRY} \
	-u ${DOCKER_REGISTRY_USER}  --password-stdin \
   	|| { echo "Docker 로그인 실패"; exit 1; }


# 2. packaging
helm package ${HELM_NAME}

# 3. push (upload to Harbor)
helm push ${HELM_PKG_NAME}-${VERSION}.tgz oci://${DOCKER_REGISTRY}/helm-charts

echo "Chart pushed to: oci://${DOCKER_REGISTRY}/helm-charts/${HELM_PKG_NAME}:${VERSION}"


helm show chart oci://${DOCKER_REGISTRY}/helm-charts/${HELM_PKG_NAME} --version ${VERSION}
