# 도커 보안

Docker 보안 강화 실습
- 도커 컨테이너의 보안을 강화하기 위한 다양한 설정과 실습을 진행합니다. 주요 보안 설정 체크리스트를 작성하고, 각 설정을 실제 환경에 적용하여 그 결과를 문서화합니다. 이를 통해 도커 컨테이너의 보안 수준을 높이고, 잠재적인 보안 위협을 최소화합니다.

Docker Security Cheat Sheet
- https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html

## 규칙 0 - 호스트와 도커를 최신상태로 유지하라
Leaky Vessel
- https://snyk.io/blog/cve-2024-21626-runc-process-cwd-container-breakout/
- WORKDIR 명령으로 호스트의 루트 파일 시스템에 접근할 수 있음.
- 호스트의 파일 시스템을 접근하고 루트 명령을 실행할 수 있음.

호스트의 커널이 취약하면 컨테이너도 똑같이 취약함.

호스트와 도커를 항상 최신 상태로 유지하는 것이 중요함




## 규칙 1 - 도커 데몬 소켓을 노출하지 마라 (컨테이너에게도)
도커는 UNIX 소켓 `/var/run/docker.sock`를 듣고 있다.
- 도커 API에 접근하는 경로
- 이 소켓의 소유자는 루트
- 이 소켓에 대한 접근은 호스트에 루트로서 접근하는 것과 같음

TCP 도커 데몬 소켓을 활성화하지 마라.
- 도커 데몬을 실행할 때 `-H tcp://0.0.0.0:XXX`를 사용하지 마라.
- 호스트가 인터넷과 연결되어있다면 공개 인터넷의 누구나 당신의 도커 데몬에 접근할 수 있다는 의미이다.

`/var/run/docker.sock`를 다른 컨테이너에게 노출하지 마라.
- 이미지를 실행할 때 `-v /var/run/docker.sock://var/run/docker.sock`를 쓰지 마라.
- 읽기 전용으로 소켓을 마운트하는 것은 침입하는 일을 약간 더 어렵게 만들 뿐이다.


## 규칙 2 - 유저를 만들어라
컨테이너가 권한이 없는 유저를 사용하게 해라. 세가지 방법을 사용할 수 있다.

(1) 런타임: `docker run` 명령에서 `-u`옵션을 사용
  ```
  docker run -u 4000 alpine
  ```

(2) 빌드 타임: Dockerfile에 유저를 추가
  ```dockerfile
  FROM alpine
  RUN groupadd -r myuser && useradd -r -g myuser myuser
  #    <HERE DO WHAT YOU HAVE TO DO AS A ROOT USER LIKE INSTALLING PACKAGES ETC.>
  USER myuser
  ```

(3) 도커 데몬: 유저 네임스페이스 활성화
- `--userns-remap=default`
- 규칙 11을 사용하면 더욱 안전하다.


쿠버네티스에서는 `.spec.containers.securityContext.runAsUser`를 설정한다.
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: example
  spec:
    containers:
      - name: example
        image: gcr.io/google-samples/node-hello:1.0
        securityContext:
          runAsUser: 4000 # <-- This is the pod user ID
  ```


## 규칙 3 - 권한을 제한해라 (컨테이너에게 필요한 권한만 부여해라)
`docker run`에서
- 권한을 추가 `--cap-add`
- 권한을 삭제 `--cap-drop`
- **절대로 `--privileged` 플래그를 사용하지 마라.**

가장 안전한 방법은 모든 권한을 삭제하는 것이다.
```
docker run --cap-drop all --cap-add CHOWN alpine
```



## 규칙 4 - 컨테이너에서 권한 확대를 예방해라
항상 도커 이미지를 실행할 때 `--security-opt=no-new-privileges`를 써라.
- 컨테이너가 `setuid` 또는 `setgid`를 쓰는 것을 예방해준다.

쿠버네티스: `allowPrivilegeEscalation`
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: example
  spec:
    containers:
      - name: example
        image: gcr.io/google-samples/node-hello:1.0
        securityContext:
          allowPrivilegeEscalation: false
  ```


## 규칙 5 - Inter-Container Connectivity
Inter-Container Connectivity (icc)
- 기본적으로 활성화됨: 모든 컨테이너가 `docker0` 브릿지 네트워크를 통해 서로 소통할 수 있음
- `--icc=false`플래그는 별로임: 모든 icc를 차단
- 특정 네트워크를 정의하는 것이 좋음



## 규칙 6 - Linux Security Module
**절대로 기본 보안 프로필을 비활성화하지 마라.**

[`seccomp`](https://docs.docker.com/engine/security/seccomp/) 또는 [`AppArmor`](https://docs.docker.com/engine/security/apparmor/)를 사용해라.

`seccomp`
- 입력된 보안 프로필에 따라 시스템 콜을 차단
  ```
  $ docker run --rm \
    -it \
    --security-opt seccomp=/path/to/seccomp/profile.json \
    hello-world
  ```

`AppArmor`
- OS와 앱을 보한 위협에서 보호
  ```
  새 프로필을 AppArmor에 로드
  $ apparmor_parser -r -W /path/to/your_profile

  커스텀 프로필로 컨테이너 실행
  $ docker run --rm -it --security-opt apparmor=your_profile hello-world
  ```


## 규칙 7 - 자원을 제한해라
DoS 공격을 방어하는 최고의 방법은 자원을 제한하는 것이다.
- [메모리 제한하기](https://docs.docker.com/engine/containers/resource_constraints/#memory)
- [CPU 제한하기](https://docs.docker.com/engine/containers/resource_constraints/#cpu)
- 최대 재실행 횟수 `--restart=on-failure:<number_of_restarts>`
- 최대 파일 디스크립터 개수 `--ulimit nofile=<number>`
- 최대 프로세스 개수 `--ulimit nproc=<number>`



## 규칙 8 - 파일시스템과 볼륨을 읽기 전용으로 설정해라
컨테이너 파일 시스템을 읽기 전용으로 실행해라
  ```
  docker run --read-only alpine sh -c 'echo "whatever" > /tmp'
  ```

애플리케이션이 임시로 정보를 저장해야한다면
  ```
  docker run --read-only --tmpfs /tmp alpine sh -c 'echo "whatever" > /tmp/file'
  ```

도커 컴포즈에서
```yaml
version: "3"
services:
  alpine:
    image: alpine
    read_only: true
```

쿠버네티스에서
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  containers:
    - name: example
      image: gcr.io/google-samples/node-hello:1.0
      securityContext:
        readOnlyRootFilesystem: true
```

볼륨은 읽기 전용으로 마운트해라.
```
docker run -v volume-name:/path/in/container:ro alpine
docker run --mount source=volume-name,destination=/path/in/container,readonly alpine
```



## 규칙 9 - CI/CD 파이프라인에 컨테이너 스캐닝 툴을 포함해라
Dockerfile을 검사하는 단계를 추가하면 두통을 피할 수 있다.
- `USER`가 명시되어야 한다.
- 베이스 이미지 버전이 고정되어야 한다.
- OS 패키지 버전이 고정되어야 한다.
- `COPY`를 사용하고 `ADD`를 사용하지 않아야 한다. ([도커 블로그](https://www.docker.com/blog/docker-best-practices-understanding-the-differences-between-add-and-copy-instructions-in-dockerfiles/))
- `RUN` 지시에서 curl bashing (`curl | bash`)를 사용하지 않는다.

컨테이너 스캐닝 툴은 아주 중요함
- 컨테이너 이미지에서 알려진 취약점, 비밀 문자, 잘못된 설정 탐지
- 해결 방법을 제시

인기있는 컨테이너 스캐닝 툴
- 무료
  - Clair
  - Threatmapper
  - Trivy
- 상업
  - Snyk
  - Anchore
  - Docker Scout
  - JFrog XRay
  - Qualys

이미지에서 비밀 문자를 탐지
- ggshield
- SecretScanner

쿠버네티스에서 잘못된 설정 탐지
- kubeaudit
- kubesec.io
- kube-bench

도커에서 잘못된 설정 탐지
- inspec.io
- dev-sec.io
- Docker Bench for Security



## 규칙 10 - 도커 데몬 로그 레벨을 info로 유지해라
도커 데몬 기본 로그 레벨은 `info`임.
- 올바른 로그 레벨을 사용하면 나중에 검토할 수 있음.
- 필요한 경우가 아니라면 'debug'레벨을 사용하지 않을 것.



## 규칙 11 - 도커를 Rootless 모드로 실행해라
Rootless 모드: 도커 데몬과 컨테이너가 권한이 없는 유저로 실행됨
- 공격자가 컨테이너를 벗어나도 호스트에 대해 권한이 없음
- Attack surface를 상당히 줄일 수 있음
- `userns-remap`모드는 rootless가 아니다.

도커 대신 Podman를 고려해라.



## 규칙 12 - Docker Secret를 활용해라
Docker Secret은 민감한 정보를 관리하는 안전한 방법을 제공한다.
- 비밀번호, 토큰, SSH 키
- 컨테이너 이미지나 런타임 명령에서 민감한 정보를 노출하지 않게 해준다.
  ```
  docker secret create my_secret /path/to/super-secret-data.txt
  docker service create --name web --secret my_secret nginx:latest
  ```

도커 컴포즈
```yaml
version: "3.8"
secrets:
  my_secret:
    file: ./super-secret-data.txt
services:
  web:
    image: nginx:latest
    secrets:
      - my_secret
```



## 규칙 13 - Supply Chain 보안을 강화해라
규칙 9 (스캐닝 툴)의 원칙을 확장해서 컨테이너 이미지의 모든 생명주기를 검사한다.
- Image Provenance
  - 컨테이너 이미지의 출처와 기록을 문서화
- SBOM Generation
  - 이미지의 컴포넌트, 라이브러리, 의존 관계 등 모든 세부사항을 기록한 소프트웨어 자재 명세서 만들기 (Software Bill of Materials)
- Image Signing
  - 이미지의 전자 서명을 생성
- Trusted Registry
  - 안전한 레지스트리에 문서, 서명된 이미지, SBOM을 저장한다.
  - 접근을 엄격하게 통제한다.
  - 메타데이터를 관리한다.
- Secure Deployment
  - 이미지 검증
  - 런타임 보안
  - 지속적인 모니터링


## Podman을 써라
도커보다 더 안전하고 가볍게 설계되었다.
1. 데몬이 없는 아키텍처
2. Rootless 컨테이너
3. SELinux 통합
