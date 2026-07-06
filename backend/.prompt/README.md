# 백엔드 개발 에이전트 프롬프트 사용 가이드

## 📋 개요

이 디렉토리에는 AI Agent가 자율적으로 백엔드 개발을 수행할 수 있도록 하는 프롬프트와 템플릿이 포함되어 있습니다.

## 📄 파일 구조

```
.prompt/
├── backend-agent-prompt.md          # 백엔드 개발 에이전트 프롬프트
├── document-generator-prompt.md     # 문서 생성 에이전트 프롬프트
├── templates/
│   ├── PROJECT_OVERVIEW.template.md
│   └── DEVELOPMENT_RULES.template.md
└── README.md                        # 이 파일
```

## 🎯 사용 시나리오

### 시나리오 1: 문서가 이미 있는 경우

**상황**: PROJECT_OVERVIEW.md와 DEVELOPMENT_RULES.md가 이미 작성되어 있음

**사용 프롬프트**: `backend-agent-prompt.md`

**절차**:
1. `backend-agent-prompt.md`의 내용을 AI Agent에게 전달
2. AI Agent가 2개 문서를 읽고 분석
3. AI Agent가 REQUIREMENTS.md와 PLAN.md 생성
4. AI Agent가 Sprint별로 개발 진행

### 시나리오 2: 문서가 없는 경우 (처음 시작)

**상황**: 프로젝트 아이디어만 있고 문서가 없음

**사용 프롬프트**: `document-generator-prompt.md` → `backend-agent-prompt.md`

**절차**:
1. `document-generator-prompt.md`의 내용을 AI Agent에게 전달
2. AI Agent가 Q&A 방식으로 질문
3. 사용자가 답변
4. AI Agent가 PROJECT_OVERVIEW.md와 DEVELOPMENT_RULES.md 생성
5. 문서 검토 및 수정
6. `backend-agent-prompt.md`로 개발 시작

## 🚀 상세 사용 방법

### 방법 1: 문서 생성부터 시작

#### Step 1: 문서 생성 에이전트 실행
```
[document-generator-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 경로]

프로젝트 문서를 생성해주세요.
```

#### Step 2: Q&A 진행
AI Agent의 질문에 답변하며 문서 내용 구체화

#### Step 3: 문서 검토
생성된 PROJECT_OVERVIEW.md와 DEVELOPMENT_RULES.md 검토 및 수정

#### Step 4: 개발 에이전트 실행
```
[backend-agent-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 경로]

작업을 시작해주세요.
```

### 방법 2: 문서가 이미 있는 경우

#### Step 1: 문서 준비
- PROJECT_OVERVIEW.md 작성
- DEVELOPMENT_RULES.md 작성

#### Step 2: 개발 에이전트 실행
```
[backend-agent-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 경로]

작업을 시작해주세요.
```

## 📚 필요한 문서

### 입력 문서 (사용자 또는 문서 생성 에이전트가 작성)
1. **PROJECT_OVERVIEW.md**: 프로젝트 개요
2. **DEVELOPMENT_RULES.md**: 개발 규칙

### 생성 문서 (개발 에이전트가 작성)
1. **REQUIREMENTS.md**: 요구사항 명세서
2. **PLAN.md**: 작업 계획서

### 결과물 (개발 에이전트가 생성)
- 완성된 백엔드 코드
- HTTP Client 테스트 파일
- 설정 파일

## 💡 템플릿 활용

### 템플릿 수정
프로젝트 특성에 맞게 템플릿을 수정할 수 있습니다:
- `templates/PROJECT_OVERVIEW.template.md`
- `templates/DEVELOPMENT_RULES.template.md`

### 템플릿 기반 수동 작성
템플릿을 참고하여 직접 문서를 작성할 수도 있습니다.

## ⚠️ 주의사항

### 문서 품질
- 문서가 상세하고 명확할수록 결과물의 품질이 높아집니다
- 모호한 내용은 AI Agent가 임의로 해석할 수 있습니다
- 중요한 요구사항은 명확히 명시하세요

### Q&A 진행 시
- 충분한 시간을 가지고 답변하세요
- 불명확한 질문은 AI Agent에게 다시 물어보세요
- 예시를 요청하면 더 쉽게 이해할 수 있습니다

### 검토 필수
- AI Agent가 생성한 문서를 반드시 검토하세요
- 잘못된 내용이나 누락된 내용을 수정하세요
- 문서 확정 후 개발을 시작하세요

## 🔗 관련 문서

현재 프로젝트의 예시:
- `../PROJECT_OVERVIEW.md`: 생성된 프로젝트 개요 예시
- `../DEVELOPMENT_RULES.md`: 생성된 개발 규칙 예시
- `../REQUIREMENTS.md`: AI Agent가 생성한 요구사항 명세서
- `../PLAN.md`: AI Agent가 생성한 작업 계획서

---

**이 프롬프트와 템플릿을 사용하면 모든 백엔드 프로젝트에서 문서 생성부터 개발까지 자동화할 수 있습니다.**


## 🎯 목적

프로젝트 요구사항이 정의되면 백엔드 API 개발을 자동화하기 위한 범용 프롬프트입니다.
이 프롬프트를 사용하면 AI Agent가:
1. 제공된 문서를 분석
2. 요구사항 명세서 작성
3. 작업 계획서 작성
4. 개발 진행
5. 테스트 및 검증
6. 문서 업데이트

이 모든 과정을 자율적으로 수행합니다.

## 📚 필요한 문서

프롬프트를 사용하기 전에 다음 2개 문서를 준비해야 합니다:

### 1. PROJECT_OVERVIEW.md (필수)
프로젝트 개요 및 개발 가이드

**포함 내용**:
- 프로젝트 목적
- 기술 스택 (Java/Spring Boot, Node.js/Express 등)
- 구현할 주요 기능 목록
- 데이터 모델 개요
- 인프라 현대화 단계 (해당되는 경우)
- 개발 우선순위 (Sprint별)

**예시 구조**:
```markdown
# Project Overview

## 목적
- 인프라 현대화 데모를 위한 이커머스 애플리케이션

## 기술 스택
- Language: Java 17
- Framework: Spring Boot 4.0.0
- Database: H2 → MySQL

## 구현할 기능
1. 상품 관리
2. 사용자 관리
3. 주문 관리
4. 장바구니 관리

## 개발 우선순위
Sprint 1: 기본 기능
Sprint 2: 주문 기능
...
```

### 2. DEVELOPMENT_RULES.md (필수)
개발 규칙 및 코딩 컨벤션

**포함 내용**:
- 구현 순서 (예: DTO → Service → Controller)
- 패키지 구조
- 네이밍 컨벤션
- 코딩 스타일 (Clean Code, Effective Java 등)
- Entity-DTO 분리 원칙
- 트랜잭션 규칙
- 예외 처리 규칙
- 테스트 방법 (HTTP Client 등)
- Git 커밋 규칙

**예시 구조**:
```markdown
# Development Rules

## 구현 순서
1. DTO 작성
2. Service 구현
3. Controller 구현
4. HTTP Client 테스트

## 네이밍 컨벤션
- Controller: {Domain}Controller
- Service: {Domain}Service
- 메서드: insert{Domain}, select{Domain}
...
```

## 🚀 사용 방법

### 1. 문서 준비
현재 디렉토리에 2개 문서를 작성합니다:
```bash
ecommerce-demo/
├── PROJECT_OVERVIEW.md
└── DEVELOPMENT_RULES.md
```

### 2. 프롬프트 전달
`backend-agent-prompt.md`의 내용을 AI Agent에게 전달합니다:

```
[backend-agent-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 디렉토리 경로]

작업을 시작해주세요.
```

### 3. AI Agent 작업 흐름
AI Agent가 자동으로:
1. 2개 문서 읽기 및 분석
2. REQUIREMENTS.md 작성
3. PLAN.md 작성
4. Sprint 0부터 개발 시작
5. 각 Sprint 완료 후 테스트
6. PLAN.md 업데이트 및 커밋
7. 모든 Sprint 완료까지 반복

### 4. 작업 이어받기
중간에 작업을 이어받으려면:

```
나는 이 백엔드 프로젝트의 개발을 이어받으려고 합니다.

현재 디렉토리: [프로젝트 디렉토리 경로]

다음을 수행해주세요:
1. PLAN.md를 읽고 현재 진행 상황을 파악하세요
2. 다음에 수행해야 할 작업을 알려주세요
3. 해당 작업을 진행하세요
4. 테스트 후 PLAN.md 업데이트 및 커밋하세요
```

## 📊 결과물

프롬프트 실행 완료 후 생성되는 파일들:

### 문서
- `REQUIREMENTS.md`: 백엔드 요구사항 명세서
- `PLAN.md`: Sprint별 작업 계획서

### 코드
- `src/`: 소스 코드 디렉토리
  - `controller/`: REST API 컨트롤러
  - `service/`: 비즈니스 로직
  - `repository/`: 데이터 접근
  - `entity/`: 데이터 모델
  - `dto/`: 데이터 전송 객체
  - `exception/`: 예외 처리
  - 기타 (프로젝트 구조에 따라)

### 테스트
- `api-tests/`: HTTP Client 테스트 파일
  - `{domain}.http`: 도메인별 API 테스트

### 설정
- `application.properties`: 환경별 설정
- `build.gradle` 또는 `pom.xml`: 빌드 설정

## 💡 활용 예시

### 다른 프로젝트에 적용
1. 새 프로젝트 디렉토리 생성
2. 2개 문서 작성 (PROJECT_OVERVIEW.md, DEVELOPMENT_RULES.md)
3. 이 프롬프트 복사
4. AI Agent에게 전달
5. 자동 개발 시작

### 팀 협업
1. 프로젝트 매니저가 PROJECT_OVERVIEW.md 작성
2. 팀 리더가 DEVELOPMENT_RULES.md 작성
3. AI Agent가 백엔드 개발 수행

## ⚠️ 주의사항

### 문서 품질
- 2개 문서가 상세하고 명확할수록 결과물의 품질이 높아집니다
- 모호한 내용은 AI Agent가 임의로 해석할 수 있습니다
- 중요한 요구사항은 명확히 명시하세요

### 기술 스택
- PROJECT_OVERVIEW.md에 기술 스택을 명확히 명시하세요
- 프레임워크 버전도 구체적으로 지정하세요

### 검토 필요
- AI Agent가 생성한 REQUIREMENTS.md와 PLAN.md를 검토하세요
- 필요시 수정 후 개발 진행하세요
- 중간 결과물도 주기적으로 검토하세요

## 🔗 관련 문서

현재 프로젝트의 예시 문서들:
- `../PROJECT_OVERVIEW.md`: 프로젝트 개요 예시 (없음 - 생성 필요)
- `../DEVELOPMENT_RULES.md`: 개발 규칙 예시
- `../REQUIREMENTS.md`: 생성된 요구사항 명세서 예시
- `../PLAN.md`: 생성된 작업 계획서 예시
- `../api-tests/`: HTTP Client 테스트 파일 예시

---

**이 프롬프트는 모든 백엔드 프로젝트에서 API 개발 자동화에 사용할 수 있습니다.**
