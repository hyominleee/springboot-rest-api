# myfirst-api-server

Spring Boot 기반의 REST API 샘플 서버입니다. User / Region CRUD, Swagger UI, Actuator 기반 헬스체크 및 Prometheus 메트릭 수집을 포함하며, Jenkins + Docker + Kubernetes CI/CD 파이프라인으로 배포됩니다.

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| Language | Java 17 |
| Framework | Spring Boot 3.4.3 |
| ORM | Spring Data JPA |
| DB (로컬) | H2 in-memory |
| DB (운영) | MariaDB |
| 문서화 | springdoc-openapi 2.1.0 (Swagger UI) |
| 모니터링 | Spring Actuator + Micrometer Prometheus |
| 빌드 | Maven |
| 컨테이너 | Docker |
| 배포 | Kubernetes (Jenkins CI/CD) |

---

## 프로젝트 구조

```
src/main/java/com/skala/springbootsample/
├── HttpRequestJpaApplication.java   # 애플리케이션 진입점
├── domain/
│   ├── User.java                    # 사용자 엔티티
│   └── Region.java                  # 지역 엔티티
├── repo/
│   ├── UserRepository.java
│   └── RegionRepository.java
├── service/
│   ├── UserService.java
│   ├── RegionService.java
│   └── LifecycleBean.java
├── controller/
│   ├── UserController.java          # /api/users
│   ├── RegionController.java        # /api/regions
│   ├── DeveloperInfoController.java # /api/developer-info
│   └── ProbeController.java         # /api/probe
├── config/
│   ├── DataInitializer.java         # 초기 데이터 삽입
│   └── DeveloperProperties.java     # developer.* 프로퍼티 바인딩
└── dto/
    ├── DeveloperInfo.java
    ├── Owner.java
    ├── Team.java
    └── ProbeStatus.java
```

---

## 도메인 모델

```
Region (1) ──── (N) User
  - id (PK)           - id (PK)
  - name (unique)     - name
                      - email (unique)
                      - region_id (FK)
```

앱 시작 시 `DataInitializer`가 초기 데이터를 자동으로 삽입합니다.


---

## API 엔드포인트

### User

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/users` | 전체 사용자 조회 (`?name=` 이름 필터 가능) |
| GET | `/api/users/{id}` | ID로 사용자 조회 |
| GET | `/api/users/region/{regionId}` | 지역 ID로 사용자 조회 |
| GET | `/api/users/region-name/{regionName}` | 지역명으로 사용자 조회 |
| POST | `/api/users` | 사용자 생성 |
| PUT | `/api/users/{id}` | 사용자 수정 |
| DELETE | `/api/users/{id}` | 사용자 삭제 |

### Region

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/regions` | 전체 지역 조회 |
| GET | `/api/regions/{id}` | ID로 지역 조회 |
| GET | `/api/regions/name/{name}` | 이름으로 지역 조회 |
| POST | `/api/regions` | 지역 생성 |
| PUT | `/api/regions/{id}` | 지역 수정 |
| DELETE | `/api/regions/{id}` | 지역 삭제 |

### 기타

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/developer-info` | 개발자 정보 조회 (yaml 설정값) |
| GET | `/api/probe` | Liveness / Readiness 상태 조회 |
| POST | `/api/probe` | Liveness / Readiness 상태 변경 |

---

## 실행 방법

### 로컬 실행

```bash
./mvnw spring-boot:run
```

기본 프로파일은 `local`이며 H2 in-memory DB를 사용합니다.

- Swagger UI: http://localhost:8080/swagger/swagger-ui
- H2 Console: http://localhost:8080/h2-console
- Actuator: http://localhost:8080/actuator

### 빌드 및 Docker 실행

```bash
# JAR 빌드
./mvnw clean package -DskipTests

# Docker 이미지 빌드
docker build -t myfirst-api-server .

# 컨테이너 실행
docker run -p 8080:8080 myfirst-api-server
```

---

## 프로파일

| 프로파일 | DB | 설명 |
|----------|----|------|
| `local` (기본) | H2 in-memory | 로컬 개발용, 재시작 시 데이터 초기화 |
| `mariadb` | MariaDB | MariaDB 연결 설정 |
| `prod` | H2 in-memory | Kubernetes 배포용 |

프로파일 지정 실행:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=mariadb
```

---

## 모니터링

Spring Actuator와 Micrometer를 통해 Prometheus 메트릭을 제공합니다.

- 메트릭 엔드포인트: `GET /actuator/prometheus`
- Liveness 프로브: `GET /actuator/health/liveness`
- Readiness 프로브: `GET /actuator/health/readiness`

Kubernetes Deployment에 Prometheus 스크레이핑 어노테이션이 설정되어 있습니다.

```yaml
annotations:
  prometheus.io/scrape: 'true'
  prometheus.io/port: '8080'
  prometheus.io/path: '/actuator/prometheus'
```

---

## CI/CD 파이프라인

Jenkins를 통해 자동 빌드 및 배포가 이루어집니다.

```
1. Git Clone  (main 브랜치)
2. Maven Build  (mvn clean package -DskipTests)
3. Docker Image Build & Push  → Harbor Registry
4. k8s/deploy.yaml 이미지 태그 업데이트
5. kubectl apply -n <YOUR_K8S_NAMESPACE> -f ./k8s
6. Rollout 완료 대기
```

### Kubernetes 리소스

- **Namespace**: 환경변수 `K8S_NAMESPACE` 참고
- **Deployment**: `<YOUR_USERNAME>-myfirst-api-server`
- **Service**: ClusterIP, 포트 8080 (HTTP), 8081 (Management)
- **Ingress**: TLS 적용 (cert-manager, nginx ingress)
