#!/bin/bash

kubectl create configmap kaniko-app-workspace \
  --from-file=Dockerfile=./Dockerfile \
  --from-file=fastserver.py=./fastserver.py \
  --namespace skala-practice
