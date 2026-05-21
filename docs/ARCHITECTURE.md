# Architecture

Bu loyiha **clean architecture** asosida qurilmoqda. Migration **feature-by-feature** olib boriladi; **auth** birinchi pilot feature, qolgan featurelar (tasks, consumers, GRS, EGXU, attendance, working-with-stamps) o'z navbatida ko'chiriladi va shu vaqtgacha eski joyida (`lib/ui/**`, `lib/core/api/**`, `lib/core/models/**`) buzilmasdan ishlaydi.

## Qatlamlar

```
presentation  →  domain  ←  data
        ↘        ↑        ↙
            core/* (error, network, usecase, di)
```

- **presentation/** — Flutter widgets, BLoCs. Faqat `domain/` (UseCase, Entity) va `core/` (theme, shared widgets) ga bog'lanadi.
- **domain/** — toza Dart. Entitylar (Equatable), repository abstract'lari, usecaselar. **Hech qachon** `dio`, `package:flutter`, `dart:io` yoki `data/` import qilmaydi.
- **data/** — Repository implementations, remote/local data sources, JSON modellar, mapperlar. `domain/` ni implement qiladi, `core/network` va `core/error` dan foydalanadi.
- **core/** — featurelar orasida ulashiladigan toza util: `error/`, `network/`, `usecase/`, `di/`.

## Folder layout (feature-first)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── injection.dart           # @InjectableInit
│   └── injection.config.dart    # generated
├── core/
│   ├── di/injection_module.dart
│   ├── error/{failures,exceptions}.dart
│   ├── network/{api_client,network_info}.dart
│   ├── network/interceptors/{auth,logging}_interceptor.dart
│   └── usecase/usecase.dart
├── features/
│   └── <feature>/
│       ├── data/{datasources,models,mappers,repositories}/
│       ├── domain/{entities,repositories,usecases}/
│       └── presentation/{bloc,pages,widgets}/
└── shared/
    ├── widgets/
    └── extensions/
```

## Naming convention

| Element              | Pattern                       | Misol                        |
|----------------------|-------------------------------|------------------------------|
| Entity               | `<Name>`                      | `User`, `Token`              |
| Model                | `<Name>Model`                 | `UserModel`                  |
| Repository contract  | `<Name>Repository`            | `AuthRepository`             |
| Repository impl      | `<Name>RepositoryImpl`        | `AuthRepositoryImpl`         |
| Remote DS interface  | `<Name>RemoteDataSource`      | `AuthRemoteDataSource`       |
| Remote DS impl       | `<Name>RemoteDataSourceImpl`  | `AuthRemoteDataSourceImpl`   |
| UseCase              | `<Verb><Object>UseCase`       | `LoginUseCase`               |
| Failure              | `<Domain>Failure`             | `AuthFailure`, `ServerFailure` |
| BLoC                 | `<Feature>Bloc`               | `LoginBloc`                  |

## Dependency direction (qattiq qoidalar)

| Qatlam        | Ruxsat etilgan import                                                   | Taqiqlangan                                                |
|---------------|-------------------------------------------------------------------------|------------------------------------------------------------|
| `domain/`     | `package:equatable`, `package:dartz`, `core/error`, `core/usecase`      | `dio`, `package:flutter`, `dart:io`, `data/`, `core/api/`  |
| `data/`       | `domain/` (interfaces), `core/network`, `core/error`, `dio`             | `presentation/`                                            |
| `presentation/` | `domain/` (UseCase + Entity), `core/`, `package:flutter_bloc`         | `data/datasources/`, `data/models/`, `core/api/`           |

Linter darajasida enforce qilish (`import_lint` yoki custom analyzer plugin) keyingi issue da.

## DI (`get_it` + `injectable`)

- `lib/app/injection.dart` — `@InjectableInit` entrypoint.
- `lib/core/di/injection_module.dart` — third-party (Dio) registratsiya.
- Har bir repository/usecase/bloc `@injectable` / `@lazySingleton` annotation oladi.
- Generate qilish: `dart run build_runner build --delete-conflicting-outputs`.
- Eski `lib/di.dart` (legacy BLoCs/APIs) **tegilmaydi** va parallel ishlashda davom etadi; har migrate qilingan feature undan asta-sekin chiqib ketadi.

## Migration roadmap

1. **Skeleton** (bu phase) — folder + core + DI bootstrap.
2. **auth pilot** — login + profile flow yangi pattern bo'yicha.
3. Tasks → Consumers → GRS → EGXU → Attendance → WorkingWithStamps — bir-bir.
4. `ApiBase` (legacy) deprecation, lint qoidalari enforce.
