# 프론트엔드 개발 에이전트 프롬프트 사용 가이드

## 📋 개요

이 디렉토리에는 AI Agent가 자율적으로 프론트엔드 개발을 수행할 수 있도록 하는 프롬프트와 템플릿이 포함되어 있습니다.

## 📄 파일 구조

```
.prompt/
├── frontend-agent-prompt.md         # 프론트엔드 개발 에이전트 프롬프트
├── document-generator-prompt.md     # 문서 생성 에이전트 프롬프트
├── templates/
│   ├── BACKEND_API.template.md
│   ├── PROJECT_OVERVIEW.template.md
│   └── DEVELOPMENT_RULES.template.md
└── README.md                        # 이 파일
```

## 🎯 사용 시나리오

### 시나리오 1: 문서가 이미 있는 경우

**상황**: BACKEND_API.md, PROJECT_OVERVIEW.md, DEVELOPMENT_RULES.md가 이미 작성되어 있음

**사용 프롬프트**: `frontend-agent-prompt.md`

**절차**:
1. `frontend-agent-prompt.md`의 내용을 AI Agent에게 전달
2. AI Agent가 3개 문서를 읽고 분석
3. AI Agent가 REQUIREMENTS.md와 PLAN.md 생성
4. AI Agent가 Phase별로 개발 진행

### 시나리오 2: 문서가 없는 경우 (처음 시작)

**상황**: 백엔드 API와 프로젝트 아이디어만 있고 문서가 없음

**사용 프롬프트**: `document-generator-prompt.md` → `frontend-agent-prompt.md`

**절차**:
1. `document-generator-prompt.md`의 내용을 AI Agent에게 전달
2. AI Agent가 Q&A 방식으로 질문
3. 사용자가 답변
4. AI Agent가 BACKEND_API.md, PROJECT_OVERVIEW.md, DEVELOPMENT_RULES.md 생성
5. 문서 검토 및 수정
6. `frontend-agent-prompt.md`로 개발 시작

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
- 반복적인 질문으로 프로덕션 수준까지 구체화
- 사용자가 생각하지 못한 부분도 발견

#### Step 3: 문서 검토
생성된 3개 문서 검토 및 수정

#### Step 4: 개발 에이전트 실행
```
[frontend-agent-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 경로]

작업을 시작해주세요.
```

### 방법 2: 문서가 이미 있는 경우

#### Step 1: 문서 준비
- BACKEND_API.md 작성
- PROJECT_OVERVIEW.md 작성
- DEVELOPMENT_RULES.md 작성

#### Step 2: 개발 에이전트 실행
```
[frontend-agent-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 경로]

작업을 시작해주세요.
```

## 📚 필요한 문서

### 입력 문서 (사용자 또는 문서 생성 에이전트가 작성)
1. **BACKEND_API.md**: 백엔드 API 명세
2. **PROJECT_OVERVIEW.md**: 프로젝트 개요
3. **DEVELOPMENT_RULES.md**: 개발 규칙

### 생성 문서 (개발 에이전트가 작성)
1. **REQUIREMENTS.md**: 요구사항 명세서
2. **PLAN.md**: 작업 계획서

### 결과물 (개발 에이전트가 생성)
- 완성된 프론트엔드 코드
- 테스트 완료
- 설정 파일

## 💡 템플릿 활용

### 템플릿 수정
프로젝트 특성에 맞게 템플릿을 수정할 수 있습니다:
- `templates/BACKEND_API.template.md`
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
- AI Agent의 제안을 적극 활용하세요
- "충분하다"고 명시적으로 말할 때까지 계속 질문받으세요

### 검토 필수
- AI Agent가 생성한 문서를 반드시 검토하세요
- 잘못된 내용이나 누락된 내용을 수정하세요
- 문서 확정 후 개발을 시작하세요

## 🔗 관련 문서

현재 프로젝트의 예시:
- `../BACKEND_API.md`: 생성된 백엔드 API 명세 예시
- `../PROJECT_OVERVIEW.md`: 생성된 프로젝트 개요 예시
- `../DEVELOPMENT_RULES.md`: 생성된 개발 규칙 예시
- `../REQUIREMENTS.md`: AI Agent가 생성한 요구사항 명세서
- `../PLAN.md`: AI Agent가 생성한 작업 계획서

---

**이 프롬프트와 템플릿을 사용하면 모든 프론트엔드 프로젝트에서 문서 생성부터 개발까지 자동화할 수 있습니다.**


## 🎯 목적

백엔드 API가 완성된 프로젝트에서 프론트엔드 개발을 자동화하기 위한 범용 프롬프트입니다.
이 프롬프트를 사용하면 AI Agent가:
1. 제공된 문서를 분석
2. 요구사항 명세서 작성
3. 작업 계획서 작성
4. 개발 진행
5. 테스트 및 검증
6. 문서 업데이트

이 모든 과정을 자율적으로 수행합니다.

## 📚 필요한 문서

프롬프트를 사용하기 전에 다음 3개 문서를 준비해야 합니다:

### 1. BACKEND_API.md (필수)
백엔드 API 상세 명세서

**포함 내용**:
- API 엔드포인트 목록
- 각 API의 요청/응답 형식
- 에러 코드 및 메시지
- 데이터 모델 (TypeScript 인터페이스 권장)
- 인증 방식
- 주요 비즈니스 로직

**예시 구조**:
```markdown
# Backend API Documentation

## 인증
- 방식: JWT / 헤더 / 세션 등

## API 엔드포인트

### 1. 사용자 API
#### 1.1 로그인
- POST /api/users/login
- Request: { email, password }
- Response: { userId, token, user }

### 2. 상품 API
...
```

### 2. PROJECT_OVERVIEW.md (필수)
프로젝트 개요 및 개발 가이드

**포함 내용**:
- 프로젝트 목적
- 기술 스택 (React, Vue, Angular 등)
- 구현할 주요 기능 목록
- 예상 프로젝트 구조
- UI/UX 가이드라인
- 개발 우선순위 (Phase별)

**예시 구조**:
```markdown
# Project Overview

## 기술 스택
- Framework: React 18+
- Build Tool: Vite
- HTTP Client: Axios

## 구현할 기능
1. 사용자 인증
2. 상품 관리
3. 장바구니
4. 주문

## 개발 우선순위
Phase 1: 프로젝트 초기 설정
Phase 2: 인증 기능
...
```

### 3. DEVELOPMENT_RULES.md (필수)
개발 규칙 및 코딩 컨벤션

**포함 내용**:
- 구현 순서 (예: Service → Component → Test)
- 프로젝트 구조 (폴더/파일 구성)
- 네이밍 컨벤션
- 코딩 스타일 (함수형/클래스형, Hooks 사용 등)
- API 호출 규칙
- 상태 관리 규칙
- 에러 처리 규칙
- 테스트 방법
- Git 커밋 규칙

**예시 구조**:
```markdown
# Development Rules

## 구현 순서
1. API Service 작성
2. 컴포넌트 구현
3. 테스트

## 네이밍 컨벤션
- 컴포넌트: PascalCase
- 함수: camelCase
...
```

## 🚀 사용 방법

### 1. 문서 준비
현재 디렉토리에 3개 문서를 작성합니다:
```bash
ecommerce-demo-frontend/
├── BACKEND_API.md
├── PROJECT_OVERVIEW.md
└── DEVELOPMENT_RULES.md
```

### 2. 프롬프트 전달
`frontend-agent-prompt.md`의 내용을 AI Agent에게 전달합니다:

```
[frontend-agent-prompt.md의 전체 내용을 복사]

현재 디렉토리: [프로젝트 디렉토리 경로]

작업을 시작해주세요.
```

### 3. AI Agent 작업 흐름
AI Agent가 자동으로:
1. 3개 문서 읽기 및 분석
2. REQUIREMENTS.md 작성
3. PLAN.md 작성
4. Phase 0부터 개발 시작
5. 각 Phase 완료 후 테스트
6. PLAN.md 업데이트 및 커밋
7. 모든 Phase 완료까지 반복

### 4. 작업 이어받기
중간에 작업을 이어받으려면:

```
나는 이 프론트엔드 프로젝트의 개발을 이어받으려고 합니다.

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
- `REQUIREMENTS.md`: 프론트엔드 요구사항 명세서
- `PLAN.md`: Phase별 작업 계획서

### 코드
- `src/`: 소스 코드 디렉토리
  - `components/`: 컴포넌트
  - `pages/`: 페이지
  - `services/`: API 서비스
  - `context/`: 상태 관리
  - `utils/`: 유틸리티
  - 기타 (프로젝트 구조에 따라)

### 설정
- `package.json`: 의존성
- `.env`: 환경 변수
- 기타 설정 파일

## 💡 활용 예시

### 다른 프로젝트에 적용
1. 새 프로젝트 디렉토리 생성
2. 3개 문서 작성 (BACKEND_API.md, PROJECT_OVERVIEW.md, DEVELOPMENT_RULES.md)
3. 이 프롬프트 복사
4. AI Agent에게 전달
5. 자동 개발 시작

### 팀 협업
1. 백엔드 개발자가 BACKEND_API.md 작성
2. 프로젝트 매니저가 PROJECT_OVERVIEW.md 작성
3. 팀 리더가 DEVELOPMENT_RULES.md 작성
4. AI Agent가 프론트엔드 개발 수행

## ⚠️ 주의사항

### 문서 품질
- 3개 문서가 상세하고 명확할수록 결과물의 품질이 높아집니다
- 모호한 내용은 AI Agent가 임의로 해석할 수 있습니다
- 중요한 요구사항은 명확히 명시하세요

### 백엔드 의존성
- 백엔드 서버가 실행 가능한 상태여야 합니다
- API 테스트가 가능해야 합니다
- CORS 설정이 필요할 수 있습니다

### 검토 필요
- AI Agent가 생성한 REQUIREMENTS.md와 PLAN.md를 검토하세요
- 필요시 수정 후 개발 진행하세요
- 중간 결과물도 주기적으로 검토하세요

## 🔗 관련 문서

현재 프로젝트의 예시 문서들:
- `../BACKEND_API.md`: 백엔드 API 명세 예시
- `../PROJECT_OVERVIEW.md`: 프로젝트 개요 예시
- `../DEVELOPMENT_RULES.md`: 개발 규칙 예시
- `../REQUIREMENTS.md`: 생성된 요구사항 명세서 예시
- `../PLAN.md`: 생성된 작업 계획서 예시

---

**이 프롬프트는 백엔드 API가 있는 모든 프로젝트에서 프론트엔드 개발 자동화에 사용할 수 있습니다.**
