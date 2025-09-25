# GitHub 인증용 Secret (필요한 경우)
apiVersion: v1
kind: Secret
metadata:
  name: ${USER_NAME}-git-credentials
  namespace: ${NAMESPACE}
type: Opaque
stringData:
  .git-credentials: https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com
  username: ${GIT_USERNAME}
  token: ${GIT_PASSWORD}
