# REVIEW — Issue #1 Clean Architecture Baseline

Branch: `feature/issue-1-clean-architecture-baseline`
Commits reviewed: `37375f5` (scaffolder), `9fe5903` (auth feature migration)
Date: 2026-05-21

## Summary
Overall verdict: **PASS**. The clean-architecture skeleton and the auth-feature migration both land cleanly. All structural, isolation, naming, DI, and acceptance-criteria checks pass. `flutter analyze` matches the scaffolder baseline (21 issues, 0 errors, 2 warnings, 19 info). `build_runner` regenerates without diff, confirming the committed `injection.config.dart` is in sync. Legacy code paths (`lib/core/api/`, `lib/core/models/`, `lib/di.dart`, `lib/global_bloc/`, `lib/global_widget/`) are untouched. Counts: **PASS = 12**, **FAIL = 0**, **FLAG = 0**.

## Detailed findings

### A. Folder layout — PASS
- `lib/core/error/` → `exceptions.dart`, `failures.dart` ✓
- `lib/core/usecase/usecase.dart` ✓
- `lib/core/network/` → `api_client.dart`, `interceptors/{auth_interceptor.dart, logging_interceptor.dart}`, `network_info.dart` ✓
- `lib/core/di/injection_module.dart` ✓
- `lib/app/injection.dart` + generated `lib/app/injection.config.dart` ✓
- `lib/features/auth/data/{datasources,mappers,models,repositories}/` populated (mappers folder kept via `.gitkeep`, intentional) ✓
- `lib/features/auth/domain/{entities,repositories,usecases}/` populated ✓
- `lib/features/auth/presentation/{bloc,pages,widgets}/` populated ✓
- `docs/ARCHITECTURE.md` present ✓
- `pubspec.yaml` — `injectable: ^2.5.0`, `injectable_generator: ^2.6.2`, `build_runner: ^2.4.13`, `dartz: ^0.10.1` ✓

### B. Domain isolation — PASS
Grep on `lib/features/auth/domain/` for forbidden imports (`package:dio`, `package:flutter/`, `features/auth/data/`, `core/api/`, `core/hive/`, `core/network/`): **0 matches**. Domain only imports `package:equatable`, `package:dartz`, `package:injectable`, `core/error/failures.dart`, `core/usecase/usecase.dart`, and same-layer files. DIP held.

### C. Presentation isolation — PASS
Grep on `lib/features/auth/presentation/` for forbidden imports (`package:dio`, `features/auth/data/`, `core/api/`, `core/hive/`): **0 matches**.
- `login_bloc.dart` depends only on use-cases + domain entities (`lib/features/auth/presentation/bloc/login_bloc.dart:5–9`).
- `login_screen.dart` imports `flutter`, `flutter_bloc`, `core/extension`, `core/utils`, `global_widget`, and the BLoC — no data-layer or `dio` leakage (`lib/features/auth/presentation/pages/login_screen.dart:1–13`).

### D. Data ↔ domain direction — PASS
Data imports from domain: `auth_repository_impl.dart:6–8` imports `domain/entities/{auth_token,user}` + `domain/repositories/auth_repository.dart`; `user_model.dart:1` imports `domain/entities/user.dart`; `auth_token_model.dart:1` imports `domain/entities/auth_token.dart`.
Grep `presentation` inside `lib/features/auth/data/`: only doc-comment hits (`user_model.dart:3`, `auth_token_model.dart:3` — both `Data-layer representation`). **0 source imports** of presentation.

### E. Naming convention — PASS
- Entity: `User` (`domain/entities/user.dart:7`), `AuthToken` (`domain/entities/auth_token.dart:7`) ✓
- Model: `UserModel extends User` (`data/models/user_model.dart:8`), `AuthTokenModel extends AuthToken` (`data/models/auth_token_model.dart:4`) ✓
- Repo contract: `abstract class AuthRepository` (`domain/repositories/auth_repository.dart:9`) ✓
- Repo impl: `AuthRepositoryImpl implements AuthRepository` (`data/repositories/auth_repository_impl.dart:13`) ✓
- RemoteDS: `abstract class AuthRemoteDataSource` (`data/datasources/auth_remote_data_source.dart:7`) + `AuthRemoteDataSourceImpl` (`auth_remote_data_source_impl.dart:16`) ✓
- LocalDS: `abstract class AuthLocalDataSource` + `AuthLocalDataSourceImpl` ✓
- UseCases all end with `UseCase`: `LoginUseCase`, `LoadUserProfileUseCase`, `CheckDailyAgreementUseCase`, `LogoutUseCase` ✓
- Failures end with `Failure` (verified in `core/error/failures.dart`) ✓
- BLoC: `LoginBloc` (`presentation/bloc/login_bloc.dart:15`) ✓

### F. flutter analyze — PASS
- Total: **21 issues**, errors: **0**, warnings: **2**, info: **19**
- Identical to scaffolder baseline (21/0/2/19). No regression introduced by the auth migration.

### G. build_runner determinism — PASS
- `dart run build_runner build --delete-conflicting-outputs` → "Built with build_runner/aot in 2s; wrote 0 outputs."
- `git status` after run: clean. Committed `injection.config.dart` matches generator output exactly.

### H. External references rewired — PASS
- Grep `package:m_gaz/ui/auth/login/` across `lib/`: **0 matches**. All callers updated to `package:m_gaz/features/auth/...`.

### I. Old auth files deleted — PASS
- `lib/ui/auth/login/` directory removed from working tree (`ls` returns "No such file or directory").
- Git diff shows D status for `lib/ui/auth/login/bloc/login_bloc.dart`, `login_event.dart`, `login_state.dart`, and `login_screen.dart`.
- `lib/ui/auth/` retains only `attendance/` and `splash/` subdirs as expected.

### J. Legacy code untouched — PASS
`git diff 37375f5^..HEAD --stat` against `lib/core/api/ lib/core/models/ lib/global_bloc/ lib/global_widget/ lib/di.dart` returns **no output** — zero lines changed in any of those paths.
Files modified outside `lib/features/`, `lib/core/`, `lib/app/`, `lib/shared/` are exactly the expected rewiring set + `main.dart`:
- `lib/ui/auth/splash/splash_screen.dart` ✓ (expected)
- `lib/ui/home/profile/profile_screen.dart` ✓ (expected)
- `lib/ui/home/profile/pages/profile_info/profile_info_screen.dart` ✓ (expected)
- `lib/ui/home/working_with_consumers/sub_page/create/create.dart` ✓ (expected)
- `lib/ui/home/working_with_consumers/sub_page/create/bloc/egxu_create_event.dart` ✓ (expected)
- `lib/main.dart` (+3/-1 lines) — bootstrap wiring, acceptable.

### K. Issue #1 acceptance criteria
1. **Project structure clean-architecture asosida qayta tartiblangan** — PASS (see A).
2. **Domain qatlami Flutter/UI va API implementation detallariga bog'lanmaydi** — PASS (see B).
3. **Presentation qatlami to'g'ridan-to'g'ri API service yoki data source chaqirmaydi** — PASS (see C; BLoC depends on use-cases only).
4. **Kamida bitta existing flow yangi architecture pattern bo'yicha ishlaydi** — PASS (auth/login flow fully migrated, DI-wired, callers rewired).
5. **`flutter analyze` critical error bermaydi** — PASS (0 errors).
6. **Keyingi issue'lar uchun `dev` dan branch ochilishi mumkin bo'lgan stable baseline** — PASS (clean tree, deterministic codegen, baseline parity).

### L. DI wiring sanity — PASS
`lib/app/injection.config.dart` registers exactly the expected graph (single occurrence each, no duplicates):
- `Dio` lazySingleton via `RegisterModule` (line 44)
- `ApiClient` lazySingleton (line 45)
- `NetworkInfo` lazySingleton (line 49)
- `AuthLocalDataSource` → `AuthLocalDataSourceImpl` (lines 46–48)
- `AuthRemoteDataSource` → `AuthRemoteDataSourceImpl(ApiClient, AuthLocalDataSource)` (lines 50–55)
- `AuthRepository` → `AuthRepositoryImpl(AuthRemoteDataSource, AuthLocalDataSource)` (lines 56–61)
- `CheckDailyAgreementUseCase`, `LoadUserProfileUseCase`, `LoginUseCase`, `LogoutUseCase` factories (lines 62–73)
- `LoginBloc(LoginUseCase, LoadUserProfileUseCase, CheckDailyAgreementUseCase)` factory (lines 74–80)

## Verdict
**PASS**

## Action items (if any)
None. Baseline is stable and ready for follow-up issues to branch from `dev` once this PR merges.

Note (informational, non-blocking): `AuthLocalDataSourceImpl` still bridges to the legacy `core/hive/api_hive.dart` and `core/models/user/token_model.dart` (`lib/features/auth/data/datasources/auth_local_data_source_impl.dart:4–5`). This is intentional during migration and isolated to the data layer — domain/presentation remain clean. Future issues can replace the legacy Hive box with a feature-local cache without touching higher layers.
