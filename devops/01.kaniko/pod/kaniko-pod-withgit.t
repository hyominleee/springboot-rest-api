apiVersion: v1
kind: Pod
metadata:
  name: ${USER_NAME}-kaniko-pod
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}
spec:
  # Init Container: Maven 빌드
  initContainers:
  - name: maven-build
    image: maven:3.8.5-openjdk-17
    workingDir: /workspace
    command: ["/bin/bash"]
    args:
      - -c
      - |
        echo "=== Git Clone 시작 ==="
        git clone ${GIT_REPO_URL_WITH_CRED} .
        echo "=== Maven 빌드 시작 ==="
        mvn clean install -DskipTests
        echo "=== 빌드 완료 ==="
        ls -al
    env:
      - name: GIT_USERNAME
        valueFrom:
          secretKeyRef:
            name: ${USER_NAME}-git-credentials
            key: username
      - name: GIT_PASSWORD
        valueFrom:
          secretKeyRef:
            name: ${USER_NAME}-git-credentials
            key: token
    volumeMounts:
      - name: workspace
        mountPath: /workspace
      - name: git-credentials
        mountPath: /root/.git-credentials
        subPath: .git-credentials
        readOnly: true

  # Main Container: Kaniko 빌드 (기본 entrypoint만 사용)
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    # command 없음 - 기본 entrypoint(/kaniko/executor) 사용
    args:
      - --dockerfile=/workspace/Dockerfile
      - --context=dir:///workspace
      - --destination=${DOCKER_REGISTRY}/${USER_NAME}-${IMAGE_NAME}:${VERSION}.spring-kaniko-kube
      - --verbosity=debug
    volumeMounts:
      - name: workspace
        mountPath: /workspace
      - name: kaniko-secret
        mountPath: /kaniko/.docker
        readOnly: true

  restartPolicy: Never
  volumes:
    - name: workspace
      emptyDir: {}
    - name: kaniko-secret
      secret:
        secretName: harbor-registry-secret
        items:
          - key: .dockerconfigjson
            path: config.json
    - name: git-credentials
      secret:
        secretName: ${USER_NAME}-git-credentials
        items:
          - key: .git-credentials
            path: .git-credentials
