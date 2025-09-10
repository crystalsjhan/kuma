# Plant Community App - 아키텍처 가이드

이 문서는 Flutter 공식 문서의 권장 아키텍처를 기반으로 구성된 프로젝트 구조를 설명합니다.

## 📁 폴더 구조

```
lib/
├── main.dart                 # 앱 진입점
├── core/                     # 핵심 기능 및 공통 요소
│   ├── constants/           # 앱 전반에서 사용되는 상수들
│   ├── errors/              # 에러 처리 및 커스텀 예외
│   └── utils/               # 유틸리티 함수들
├── data/                     # 데이터 레이어
│   ├── datasources/         # 데이터 소스 (API, 로컬 DB 등)
│   ├── models/              # 데이터 모델 (JSON 직렬화/역직렬화)
│   └── repositories/        # 데이터 레포지토리 구현체
├── domain/                   # 도메인 레이어 (비즈니스 로직)
│   ├── entities/            # 비즈니스 엔티티
│   ├── repositories/        # 레포지토리 인터페이스
│   └── usecases/            # 비즈니스 로직 (Use Cases)
├── presentation/             # 프레젠테이션 레이어 (UI)
│   ├── pages/               # 화면/페이지 위젯들
│   ├── providers/           # 상태 관리 (Provider, Bloc 등)
│   └── widgets/             # 재사용 가능한 UI 컴포넌트들
├── di/                       # 의존성 주입 설정
└── services/                 # 외부 서비스 (Firebase, API 등)
```

## 🏗️ 아키텍처 레이어 설명

### 1. Core Layer (핵심 레이어)
- **constants/**: 앱 전반에서 사용되는 상수값들 (API URL, 앱 설정 등)
- **errors/**: 커스텀 예외 클래스 및 에러 처리 로직
- **utils/**: 공통으로 사용되는 유틸리티 함수들

### 2. Data Layer (데이터 레이어)
- **datasources/**: 외부 데이터 소스와의 통신 (API, 로컬 데이터베이스)
- **models/**: JSON 직렬화/역직렬화를 위한 데이터 모델
- **repositories/**: 데이터 레포지토리의 구체적인 구현체

### 3. Domain Layer (도메인 레이어)
- **entities/**: 비즈니스 로직의 핵심이 되는 엔티티
- **repositories/**: 데이터 접근을 위한 추상화된 인터페이스
- **usecases/**: 특정 비즈니스 로직을 수행하는 Use Case 클래스들

### 4. Presentation Layer (프레젠테이션 레이어)
- **pages/**: 각 화면을 나타내는 페이지 위젯들
- **providers/**: 상태 관리 (Provider, Bloc, Riverpod 등)
- **widgets/**: 재사용 가능한 UI 컴포넌트들

### 5. Dependency Injection (의존성 주입)
- **di/**: 의존성 주입 설정 및 서비스 로케이터
- **services/**: 외부 서비스와의 통신을 담당하는 서비스 클래스들

## 🔄 데이터 흐름

1. **UI (Presentation)** → **Use Case (Domain)** → **Repository (Domain)**
2. **Repository (Data)** → **Data Source (Data)** → **External API/DB**
3. **Data Source** → **Model (Data)** → **Entity (Domain)** → **UI**

## 📋 개발 가이드라인

### 파일 명명 규칙
- **Pages**: `home_page.dart`, `login_page.dart`
- **Widgets**: `custom_button.dart`, `plant_card.dart`
- **Models**: `plant_model.dart`, `user_model.dart`
- **Entities**: `plant.dart`, `user.dart`
- **Use Cases**: `get_plants_usecase.dart`, `login_usecase.dart`
- **Repositories**: `plant_repository_impl.dart`
- **Data Sources**: `plant_remote_datasource.dart`

### 의존성 방향
- **Presentation** → **Domain** (Use Cases, Entities)
- **Domain** → **Data** (Repository Interfaces)
- **Data** → **Domain** (Repository Implementations)
- **Core**는 모든 레이어에서 사용 가능

## 🚀 다음 단계

1. 각 폴더에 적절한 파일들을 생성
2. 의존성 주입 설정 (get_it, injectable 등)
3. 상태 관리 라이브러리 설정 (Provider, Bloc, Riverpod 등)
4. API 통신을 위한 HTTP 클라이언트 설정
5. 로컬 데이터베이스 설정 (SQLite, Hive 등)

## 📚 참고 자료

- [Flutter App Architecture 공식 문서](https://docs.flutter.dev/app-architecture)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)

