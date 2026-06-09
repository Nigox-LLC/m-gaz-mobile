# CLAUDE.md

This file gives Claude Code repository-specific guidance for working in this project.

## Project

`m_gaz` is a Flutter mobile app for M-Gaz field operations: gas measurement devices, consumer documents, technological measuring, stamps, attendance, profile, and task workflows.

- Backend: `https://backend.m-gaz.uz/api/`
- Dart SDK: `^3.9.2`
- Default branch: `dev`
- Main target: mobile Flutter app

## Common Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
flutter analyze
flutter test
flutter test path/to/file_test.dart
flutter run
flutter build apk --debug
flutter build apk --release
```

After modifying any `@injectable`, `@LazySingleton`, or `@module` annotation, rerun:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Otherwise `lib/app/injection.config.dart` will be stale.

## Current Quality Baseline

`flutter analyze` currently reports 11 info-level diagnostics and 0 errors. Do not increase the count.

Known baseline categories:

- Deprecated Flutter APIs in existing code.
- Non-snake-case legacy model filenames.
- Nullable generic null-check warnings in `global_dropdown.dart`.
- Existing async `BuildContext` lint warnings in attendance/profile settings code.

When a task touches one of those files, fix diagnostics that are directly caused by the edit. Do not expand unrelated refactors just to clean the baseline unless explicitly requested.

## Architecture

The repo is mid-migration to clean architecture. Two stacks coexist.

### New Clean Architecture Stack

```text
lib/
  app/
    app.dart
    injection.dart
    injection.config.dart
  core/
    di/injection_module.dart
    error/
    network/
    usecase/
  features/<feature>/
    data/
    domain/
    presentation/
```

Layer rules:

| Layer | Allowed imports | Forbidden imports |
| --- | --- | --- |
| `domain/` | `equatable`, `dartz`, `core/error`, `core/usecase` | `dio`, `package:flutter`, `dart:io`, `data/`, `core/api/`, `core/hive/`, `core/network/` |
| `data/` | `domain/`, `core/network`, `core/error`, `dio`, `injectable` | `presentation/` |
| `presentation/` | `domain/`, `core/`, `flutter_bloc`, `flutter/material` | `data/datasources/`, `data/models/`, `core/api/`, `core/hive/`, `dio` |

Use cases return `Future<Either<Failure, T>>`. Repository implementations catch typed exceptions and map them to failures. BLoCs should consume use cases and emit state through `fold`.

Migration status by feature in `lib/features/`:

- `auth`, `profile`: full clean architecture (entities + repository contracts + use cases; BLoC depends on use cases). Use these as the reference pattern.
- `actions`: feature-first folders (`data/domain/presentation`) but partial — `domain/` holds entities only, no repository/use-case layer. BLoCs under `presentation/.../bloc/` call `data/datasources/*_api.dart` directly. Do not copy this as the target pattern; prefer the `auth`/`profile` shape for new work.

Cross-feature reusable code lives in `lib/shared/{widgets,extensions}`. App-wide enums (e.g. the universal `TaskStatus` in `lib/core/enums/task_status_enum.dart`, the single source of truth for task status label/color/icon/filter endpoint) live in `lib/core/enums/`.

### Legacy Stack

Most features still use the legacy layout:

```text
lib/
  di.dart
  core/api/<feature>/
  core/api/base/base_api.dart
  core/models/<feature>/
  core/hive/api_hive.dart
  ui/<feature>/
  global_bloc/
  global_widget/
```

Legacy BLoCs are still registered in `lib/app/app.dart` and often instantiate APIs through `di.get<XxxApi>()`. Do not introduce new legacy patterns into clean-architecture features.

### Bridge Between Stacks

- `lib/main.dart` runs legacy `setup()` first, then `configureDependencies()`.
- `AuthLocalDataSourceImpl` bridges to legacy storage via `GetIt.instance.get<ApiHive>()`.
- Do not register `ApiHive` again in an injectable module.
- New code should prefer `getIt` from `lib/app/injection.dart`; legacy code may still use `di` from `lib/di.dart`. Both refer to the same `GetIt.instance`.

## Migration Playbook

1. Create `lib/features/<feature>/{data,domain,presentation}/`.
2. Write domain first: entity, repository contract, use cases.
3. Write data: models extend entities, remote datasource throws typed exceptions, repository maps exception to failure.
4. Rewrite BLoC to depend on use cases only.
5. Keep event/state names stable when practical to reduce screen churn.
6. Grep for stale imports before deleting legacy files.
7. Rerun build runner after DI annotation changes.
8. Verify layer imports manually until lint rules exist.
9. Run targeted tests, then `flutter test`, then `flutter analyze`.

## Date And Time Display

User-facing date/time output is standardized:

- Date only: `dd.MM.yyyy`
- Time only: `HH:mm:ss`
- Date + time: `dd.MM.yyyy HH:mm:ss`

Use `lib/core/utils/app_date_formatter.dart` for UI text:

- `AppDateFormatter.date(...)`
- `AppDateFormatter.time(...)`
- `AppDateFormatter.dateTime(...)`
- `AppDateFormatter.dateFromString(...)`
- `AppDateFormatter.dateTimeFromString(...)`

Do not add screen-local `DateFormat(...)`, manual `padLeft(...)` string assembly, or `DateTime.toString().substring(...)` for user-facing output.

Keep API, storage, and backend wire formats unchanged unless the API contract explicitly changes. Examples that should usually stay unchanged: `toIso8601String()`, backend `yyyy-MM-dd`, route timestamps, and request payloads.

After touching date/time display code, run:

```bash
flutter test test/core/utils/app_date_formatter_test.dart
flutter test
rg -n 'DateFormat\(|toString\(\)\.substring|dd MMM|HH:mm|padLeft\(2' lib test
```

The `rg` result should be limited to the central formatter, tests, comments, or non-user-facing API/background helpers.

## Auth Behavior To Preserve

- Login persists token through `AuthLocalDataSource.saveToken` to `ApiHive.putToken`.
- `LoginBloc._onSubmitted` checks the daily agreement after login success.
- If the stored agreement date differs from today, login routes to `AgreementPdfScreen`; otherwise it routes to `HomeScreen`.
- `SplashScreen` triggers `LoadUserProfile` for auto-login.
- On 401, the auth repository purges local auth state.
- `AuthRemoteDataSourceImpl.loadProfile` currently adds `Authorization: Bearer <token>` manually because `AuthInterceptor` is not wired into `ApiClient` yet.

## Localization

Localization uses `easy_localization`.

- Translation files: `assets/tr/`
- Locales: `uz_UZ` default, `ru_RU`, `en_EN`, `uz_Cyrl`
- `Words` keys live in `lib/core/common/words.dart`

When adding a `Words` key, update all translation files and run `flutter test`; the translation coverage test should catch missing keys.

## Git And PR Workflow

- Branch from up-to-date `dev`.
- Use focused branch names, preferably `feature/<issue-or-topic>`.
- PRs target `dev`.
- Use `Refs #N` for in-progress work and `Closes #N` only when the issue is fully complete.
- Stage only files that belong to the issue. Inspect `git status --short --branch` and `git diff --stat` before committing.
- Prefer a concise Conventional Commit style message.
- Before publishing, run the relevant targeted tests and `flutter test`.
- Run `flutter analyze`. If it fails only because of the documented baseline info-level diagnostics, mention that in the PR.
- After merge, verify PR state, issue state, current branch, and clean worktree.

## General Editing Rules

- Prefer existing project patterns and widgets over new abstractions.
- Keep changes tightly scoped to the issue.
- Do not edit generated files manually.
- Do not modify backend/API contracts unless the task explicitly asks for it.
- Avoid broad formatting churn. Format only files touched for the task.
- For UI changes, consider small screens, long localized text, keyboard overlap, scroll behavior, loading/empty/error states, and overflow.
