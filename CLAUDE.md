# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**m_gaz** — Flutter mobile app for M-Gaz field operations (gas measurement devices, consumer documents, technological measuring, stamps, attendance). Backend: `https://backend.m-gaz.uz/api/`. SDK: Dart `^3.9.2`.

## Common commands

```bash
flutter pub get                                          # install deps
dart run build_runner build --delete-conflicting-outputs # regen injection.config.dart (REQUIRED after adding @injectable annotations)
dart run build_runner watch --delete-conflicting-outputs # continuous regen during dev
flutter analyze                                          # static analysis (baseline: 21 issues, 0 errors — must not increase)
flutter run                                              # debug run on connected device
flutter build apk --debug                                # debug APK
flutter build apk --release                              # release APK
flutter test                                             # run all tests (no tests committed yet)
flutter test path/to/file_test.dart                      # single test file
flutter test --name "<test name substring>"              # single test by name
```

After modifying any `@injectable`, `@LazySingleton`, or `@module` annotation: **rerun build_runner** before launching, otherwise DI registration is stale.

## Architecture — split state (mid-migration)

Repo is mid-migration to clean architecture (issue #1, PR #4). **Two stacks coexist**:

### New stack — clean architecture (feature-by-feature migration)

```
lib/
├── app/
│   ├── app.dart                # root MultiBlocProvider (still global-scoped)
│   ├── injection.dart          # @InjectableInit → configureDependencies()
│   └── injection.config.dart   # GENERATED, do not edit
├── core/
│   ├── di/injection_module.dart       # @module: Dio + base URL
│   ├── error/{failures,exceptions}.dart
│   ├── network/{api_client,network_info}.dart
│   ├── network/interceptors/{auth,logging}_interceptor.dart  # NOT wired into ApiClient yet
│   └── usecase/usecase.dart           # UseCase<Type, Params>, NoParams
└── features/<feature>/
    ├── data/{datasources,models,mappers,repositories}/
    ├── domain/{entities,repositories,usecases}/
    └── presentation/{bloc,pages,widgets}/
```

**Dependency direction (HARD RULE — enforce in code review until lint added):**

| Layer | Allowed imports | Forbidden |
|-------|-----------------|-----------|
| `domain/` | `equatable`, `dartz`, `core/error`, `core/usecase` | `dio`, `package:flutter`, `dart:io`, `data/`, `core/api/`, `core/hive/`, `core/network/` |
| `data/` | `domain/` (interfaces), `core/network`, `core/error`, `dio`, `injectable` | `presentation/` |
| `presentation/` | `domain/` (UseCase + Entity), `core/`, `flutter_bloc`, `flutter/material` | `data/datasources/`, `data/models/`, `core/api/`, `core/hive/`, `dio` |

Use cases return `Future<Either<Failure, T>>` (`dartz`). Repository impls catch typed `*Exception` and map to `*Failure`. BLoCs do `result.fold((failure) => emit fail, (value) => emit success)`.

**Naming:** `User` (entity), `UserModel` (data, extends entity), `AuthRepository` (contract), `AuthRepositoryImpl`, `AuthRemoteDataSource(+ Impl)`, `LoginUseCase`, `AuthFailure`, `LoginBloc`.

Migrated so far: **auth** only (login + load profile + logout + daily-agreement check).

### Legacy stack — original code (still owns most features)

```
lib/
├── di.dart                     # legacy GetIt setup() — registers ApiBase, ApiHive, *Api classes
├── core/api/<feature>/<x>_api.dart   # Dio-backed API classes
├── core/api/base/base_api.dart       # legacy Dio wrapper (has BuildContext deps — DO NOT replicate)
├── core/models/<feature>/...         # JSON models (fromJson/toJson)
├── core/hive/api_hive.dart           # token + agreement-date storage
├── ui/<feature>/{bloc,...}.dart      # BLoCs grab API via di.get<XxxApi>() inside constructor
├── global_bloc/, global_widget/
└── core/{extension,utils,storage,...}
```

Legacy BLoCs (`TaskBloc`, `ConsumerRelationsBloc`, `TechMeasuresBloc`, `GrsMeasurementDevicesBloc`, `WorkingWithStampBloc`, `AttendanceBloc`, `GlobalBloc`) instantiated in `lib/app/app.dart` via global `MultiBlocProvider`. They violate DIP — to be migrated one by one.

### Bridge between stacks

- `lib/main.dart` order: `await setup()` (legacy `di.dart`) **then** `await configureDependencies()` (injectable). Order matters: injectable resolves `ApiHive` from `GetIt.instance` because legacy registered it first.
- `AuthLocalDataSourceImpl` is the canonical bridge example: `_hive = GetIt.instance.get<ApiHive>()` inside the impl ctor (DO NOT add `ApiHive` to `@module` — would cause duplicate registration).
- `lib/app/app.dart` mixes both: `BlocProvider<LoginBloc>(create: (_) => di.get<LoginBloc>())` (new) alongside `TaskBloc()` constructor calls (legacy).
- New `lib/core/network/api_client.dart` is UI-free. Legacy `lib/core/api/base/base_api.dart` still has `mainKey.currentContext` deps and is used by legacy APIs only.

## Migration playbook (for adding next feature to clean stack)

1. Create `lib/features/<feature>/{data,domain,presentation}/`.
2. Write domain (entity → repo contract → usecases) first.
3. Write data: model `extends` entity; remote DS throws `*Exception`; local DS bridges legacy storage via `GetIt.instance.get<...>()`; repository impl maps exception → Failure, persists state.
4. Rewrite BLoC to depend on use-cases only. Same event/state class names if possible (avoids breaking screens).
5. Grep for all references to the old BLoC / screen / model and update imports. Screen field types swap from `XxxModel` → domain `Xxx` (Equatable shape matches).
6. `dart run build_runner build --delete-conflicting-outputs`.
7. Delete old `lib/ui/<feature>/{bloc,*.dart}` and `lib/core/api/<feature>/`, but ONLY after grep confirms zero stale imports. Models in `lib/core/models/<feature>/` may need to stay if other unmigrated features reference them.
8. Verify: domain has no `dio`/`flutter`/`data` imports; presentation has no `core/api`/`data/datasources`/`data/models` imports.
9. `flutter analyze` count must not increase from baseline.

## DI gotchas

- Annotation must match registration intent: `@injectable` = factory (new instance each call, use for BLoCs); `@lazySingleton` / `@LazySingleton(as: Interface)` = single instance (use for repos, DS, ApiClient).
- After ANY annotation change → rerun build_runner or DI graph is stale.
- Legacy `lib/di.dart` exposes `di` (alias for `GetIt.instance`) and `mainKey` (`GlobalKey<NavigatorState>`). New code uses `getIt` (also `GetIt.instance`) from `lib/app/injection.dart`. Same instance — interchangeable but prefer `getIt` in new code.

## Auth-specific behavior to preserve when touching auth

- Login persists token via `AuthLocalDataSource.saveToken` → `ApiHive.putToken`.
- `LoginBloc._onSubmitted` on success calls `CheckDailyAgreementUseCase`; if today differs from `ApiHive.lastAgreementDate`, sets `state.requiresAgreement = true` and updates stored date. `LoginScreen` listener routes to `AgreementPdfScreen` vs `HomeScreen`.
- `LoadUserProfile` event triggered by `SplashScreen` for auto-login. On 401 the repository purges local state (mirrors legacy `UserApi.loadUserProfile`).
- New `AuthRemoteDataSourceImpl.loadProfile` adds `Authorization: Bearer <token>` manually per-request because `AuthInterceptor` is not yet wired into `ApiClient` (follow-up).

## Localization

`easy_localization`, files in `assets/tr/`, locales: `uz_UZ` (default), `ru_RU`, `en_EN`, `uz_Cyrl`. Init in `lib/app/app.dart`.

## Commit / PR conventions

Conventional Commits. Reference issues as `Refs #N` (in progress) or `Closes #N` (final). Branch off `dev`, PR back to `dev`. See `docs/ARCHITECTURE.md` for layered diagram and naming tables — keep it in sync if architecture rules change.
