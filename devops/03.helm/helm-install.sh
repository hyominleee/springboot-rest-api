#!/bin/bash

set -xeu

HELM_PRFIX_NAME=sk199
MY_NAME=sk2199

helm upgrade --install ${MY_NAME}-myfirst-api \
  oci://amdp-registry.skala-ai.com/skala25a/helm-charts/${HELM_PRFIX_NAME}-myfirst-api-server \
  --version 0.1.0 \
  -n skala-practice \
  --set userName=${MY_NAME}
