# M-GAZ Biometric Login Plan

## Maqsad

Foydalanuvchi M-GAZ ilovasiga username/password bilan bir marta muvaffaqiyatli kirgandan keyin, keyingi qayta kirishlarda login va parolni qayta kiritmasdan qurilmaning barmoq izi yoki Face ID orqali protected oqimga o'tishi kerak.

Talab qilinadigan oqim:

1. Birinchi login odatdagidek username/password bilan bajariladi.
2. Foydalanuvchi ilovani yopib qayta ochganda, saqlangan auth sessiya mavjud bo'lsa LoginScreen ko'rinadi va biometric system prompt avtomatik ochiladi.
3. Biometrik tekshiruv muvaffaqiyatli bo'lsa, saqlangan token bilan mavjud auth oqimi davom etadi va HomeScreen yoki amaldagi attendance gate natijasiga o'tiladi.
4. LoginScreen'da `Kirish` tugmasi ostida Figma'dagi alohida biometric tugma ko'rinadi.
5. Biometric prompt bekor qilinsa yoki ishlamasa, foydalanuvchi LoginScreen'da qoladi va username/password fallback ishlashda davom etadi.

Biometrika backendga yangi login so'rovi yubormaydi va password'ni qurilmada saqlamaydi. U faqat foydalanuvchini lokal qurilma darajasida tasdiqlab, mavjud tokenli sessiyani qayta ochish uchun ishlatiladi.

## M-GAZ loyihasiga moslashtirish xulosasi

Manba plan PIN page va `SessionBloc`ga asoslangan. M-GAZ loyihasida esa:

| Manba plandagi tushuncha | M-GAZ'dagi haqiqiy moslik |
| --- | --- |
| PIN page | `lib/features/auth/presentation/pages/login_screen.dart` |
| PIN BLoC | Mavjud `LoginBloc` |
| SessionBloc | Alohida SessionBloc yo'q; lifecycle `lib/main.dart`, cold start `SplashScreen` va `ApiHive` orqali boshqariladi |
| Secure/session storage | `ApiHive` orqali Hive box `api` |
| Username saqlash | `ApiHive.savedUsername` va `GetSavedUsernameUseCase` |
| Password login | `LoginBloc -> LoginUseCase -> AuthRepositoryImpl` |
| Login'dan keyingi route | `AttendanceBloc` natijasiga ko'ra `AgreementPdfScreen` yoki `HomeScreen` |
| Biometric paket | `pubspec.yaml`da allaqachon `local_auth: ^2.3.0` bor |

Shuning uchun yangi yechim PIN oqimini ko'chirmaydi. Mavjud `LoginBloc`, `LoginScreen`, `AttendanceBloc`, `SplashScreen` va `ApiHive` oqimiga qo'shiladi.

## Figma dizayn

Figma link:

```text
https://www.figma.com/design/o2FW6FWctsmPRyik3Qtu1q/M-GAZ-design?node-id=631-7601&m=dev
```

Aniq node: `631:7601` (`tui-button`). Figma'dan olingan dizayn parametrlari:

- o'lcham: `350 x 52 px`;
- background: `#526ED3`;
- border: `1 px`, `#E8E8E8`;
- border radius: `20 px`;
- ichki elementlar oralig'i: `8 px`;
- label: `Barmoq izi yo’ki FaceID orqali`;
- label font: Manrope SemiBold, `15 px`, line-height `24 px`;
- label color: `#FCFCFC`;
- Face ID icon: `20 x 20 px`.

Implementatsiyada Figma'dagi Face ID asset export qilinadi yoki loyihadagi mavjud SVG asset bilan almashtiriladi. Yangi icon package qo'shilmaydi. Button mavjud `LoginButton`dan alohida widget bo'ladi, chunki uning balandligi, radiusi va ranglari password login tugmasidan farq qiladi.

## Scope

### Kiritiladi

- Mavjud `local_auth ^2.3.0` paketidan foydalanish.
- Qurilmada biometric support va enrolled biometric holatini aniqlash.
- `LoginScreen`da biometric tugmani faqat saqlangan auth sessiya va available biometric mavjud bo'lganda ko'rsatish.
- Keyingi cold start yoki session timeout'dan keyin biometric prompt'ni bir marta avtomatik ochish.
- Biometric muvaffaqiyatidan keyin mavjud token bilan protected oqimni davom ettirish.
- Password login va attendance gate oqimini umumiy post-auth oqimga birlashtirish.
- Android/iOS platform sozlamalari.
- Uzbek Latin, Uzbek Cyrillic va Russian lokalizatsiyasi.
- Unit, BLoC, widget va real-device testlari.

### Kiritilmaydi

- Yangi backend login endpoint.
- Biometrika orqali yangi access/refresh token yaratish.
- Password yoki PIN'ni saqlash.
- Web, Windows, macOS yoki Linux uchun biometric UX.
- Profil/settings ichida biometric toggle qo'shish.
- Secure storage migratsiyasi. Bu alohida security task sifatida rejalashtiriladi.

## Hozirgi auth va session oqimi

### Normal login

1. `LoginScreen` username va password'ni oladi.
2. `LoginBloc` `LoginSubmitted` eventini qayta ishlaydi.
3. `LoginUseCase` backend `login/` endpointini chaqiradi.
4. `AuthRepositoryImpl` tokenlarni `AuthLocalDataSource` orqali `ApiHive`ga saqlaydi va username'ni yozadi.
5. `LoginScreen` `AttendanceCheckAccess` yuboradi.
6. Attendance ruxsatiga ko'ra `AgreementPdfScreen` yoki `HomeScreen` ochiladi.

### Hozirgi qayta kirish

- `SplashScreen` `accessToken` va `last_active_millis`ni tekshiradi.
- 5 daqiqalik `kSessionTimeout` ichida bo'lsa, token bilan to'g'ridan-to'g'ri `HomeScreen` ochiladi.
- Timeout bo'lsa, `LoginScreen`ga o'tiladi.
- `main.dart` lifecycle timeoutda tokenni o'chirmasdan login sahifasiga qaytaradi.
- `ApiHive.clear()` tokenlarni tozalaydi, lekin saved username'ni qoldiradi.
- `ApiHive.clearAll()` barcha local auth ma'lumotlarini o'chiradi.

## Yangi user flow

### 1. Birinchi login yoki token yo'q holat

```text
Splash/LoginScreen
  -> stored access/refresh token yo'q
  -> biometric button yashiriladi
  -> username/password login
  -> token saqlanadi
  -> AttendanceCheckAccess
  -> AgreementPdfScreen yoki HomeScreen
```

### 2. Keyingi cold start

```text
SplashScreen
  -> stored auth token mavjud
  -> LoginScreen(autoBiometric: true)
  -> availability tekshiriladi
  -> system biometric prompt avtomatik ochiladi
  -> success
  -> stored session tekshiriladi
  -> AttendanceCheckAccess
  -> AgreementPdfScreen yoki HomeScreen
```

Cold start'da tokenli foydalanuvchini jim holda `HomeScreen`ga o'tkazadigan hozirgi `sessionAlive -> _goHome()` branch biometric unlock oqimiga almashtiriladi. Shu bilan ilovani yopib qayta ochganda biometric prompt har safar aniq boshqariladi.

Ilova faqat background'da bo'lib, `kSessionTimeout` hali tugamagan bo'lsa, mavjud HomeScreen sessiyasi saqlanadi. Bunday holatda ortiqcha prompt ochilmaydi.

### 3. Session timeout'dan keyingi qaytish

- `main.dart`da `timedOut == true` bo'lsa, `LoginScreen(autoBiometric: true)` ochiladi.
- `pendingRelogin == true` bo'lsa, mavjud biznes/security qarori saqlanadi va oddiy login talab qilinadi; bu flag kamera/attendance oqimi uchun qo'yilgan majburiy relogin signalidir.
- Biometric prompt bekor qilinsa, login formasi faol qoladi.

### 4. Explicit logout

- Explicit logout barcha tokenlarni va biometric unlock eligibility flagini o'chiradi.
- Saved username'ni qoldirish yoki o'chirish bo'yicha mavjud product qarori saqlanadi, lekin biometric unlock token bo'lmagani uchun ishlamasligi shart.
- Barcha logout entry point'lar bitta logout use case yoki yagona session store orqali o'tkaziladi. Hozirgi profile flow'dagi `ApiHive.clear()` chaqiruvi va legacy `UserApi.logout()` alohida audit qilinadi.

## Tavsiya qilingan arxitektura

### 1. Biometric service

Platforma paketini UI va BLoC'dan ajratish:

```text
lib/features/auth/domain/services/biometric_auth_service.dart
lib/features/auth/data/services/local_biometric_auth_service.dart
```

Domain qatlamida quyidagi natijalar bo'ladi:

```dart
enum BiometricAvailability {
  unknown,
  available,
  notSupported,
  notEnrolled,
  unavailable,
}

enum BiometricResult {
  success,
  canceled,
  failed,
  lockedOut,
  unavailable,
}
```

Service mas'uliyati:

- `isDeviceSupported()` va available/enrolled biometricsni tekshirish;
- fingerprint, face unlock va Face ID'ni platformaga topshirish;
- `local_auth` exceptionlarini domain resultlariga map qilish;
- bir vaqtning o'zida ikkinchi prompt ochilishini bloklash;
- UI yoki Navigator'ga bevosita bog'lanmaslik.

`local_auth` allaqachon `pubspec.yaml`da mavjud. Paket versiyasini avtomatik yangilash shart emas; avval current Flutter/Android/iOS kombinatsiyasi bilan implement qilinadi. Major upgrade faqat API va platform compatibility tekshirilgandan keyin qilinadi.

### 2. Auth session contract

`AuthLocalDataSource` va `AuthRepository`ga session mavjudligini tekshiruvchi minimal contract qo'shiladi:

- `hasStoredSession()` yoki ekvivalent `hasUsableToken()`;
- access token va refresh token bo'shligini aniqlash;
- biometric success'dan keyin password login endpointini chaqirmaslik.

Bu tekshiruv `LoginBloc`ni `ApiHive`ga to'g'ridan-to'g'ri bog'lamasdan bajarilishi uchun use case orqali beriladi. Alohida `SessionBloc` kiritilmaydi, chunki m-gaz-mobile'da session state hozir `SplashScreen`, `main.dart` lifecycle va `ApiHive` orqali yuradi.

### 3. LoginBloc

Mavjud `LoginBloc`ga quyidagi eventlar qo'shiladi:

```text
CheckBiometricAvailability
BiometricUnlockRequested
```

`LoginState`ga quyidagi state ma'lumotlari qo'shiladi:

```text
biometricAvailability
biometricResult
isBiometricChecking
isBiometricPromptInProgress
```

BLoC oqimi:

1. `LoginScreen` ochilganda availability tekshiriladi.
2. `autoBiometric == true` va availability `available` bo'lsa prompt bir marta ishga tushadi.
3. Button bosilganda shu event qayta ishlatiladi.
4. Success'da stored session borligi tekshiriladi.
5. Token yo'q bo'lsa biometric success ham login success hisoblanmaydi; LoginScreen'da qoladi yoki login oqimiga qaytadi.
6. Token bor bo'lsa `last_active_millis` yangilanadi va umumiy post-auth callback oqimi boshlanadi.

`LoginBloc` password login'dagi mavjud `LoadUserProfile` ishlatilishini buzmaydi.

### 4. LoginScreen

`LoginScreen`ga entry mode qo'shiladi:

```text
LoginScreen(autoBiometric: false)
```

`autoBiometric` faqat Splash yoki lifecycle timeout orqali qayta kirish uchun `true` bo'ladi. Birinchi login va explicit logoutdan keyin `false` bo'ladi.

UI o'zgarishlari:

- `LoginButton` (`Kirish`) o'z joyida qoladi.
- Uning tagida Figma'dagi biometric button joylashadi.
- Button faqat `biometricAvailability == available` va stored session mavjud bo'lganda ko'rinadi.
- Prompt yoki login request davomida ikkala tugma ham double-tapdan himoyalanadi.
- Cancel/failed/lockedOut holatlarida password formasi qayta ishlashda davom etadi.
- Auto prompt cancel bo'lgandan keyin qayta avtomatik urinish qilinmaydi; foydalanuvchi buttonni o'zi bosishi mumkin.

### 5. Umumiy post-auth gate

Hozir password login'dan keyin bajariladigan attendance tekshiruvi biometric oqimida ham aynan ishlatiladi.

LoginScreen ichidagi post-auth navigation quyidagicha refactor qilinadi:

```text
password login success
biometric unlock success
  -> shared post-auth handler
  -> AttendanceCheckAccess
  -> AgreementPdfScreen yoki HomeScreen
```

Shu bilan biometric login `AttendanceBloc` biznes qoidasini chetlab o'tib, noto'g'ri ravishda HomeScreen'ga o'tib ketmaydi.

## Platform sozlamalari

### Android

Fayllar:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/raqamli/nazorat/m_gaz_mobile/MainActivity.kt`
- `android/app/build.gradle`

Ishlar:

1. Manifest'ga `android.permission.USE_BIOMETRIC` qo'shish.
2. `MainActivity`ni `FlutterActivity`dan `FlutterFragmentActivity`ga o'tkazish.
3. Hozirgi `minSdk = 26` saqlanadi; bu biometric paketining minimum talabidan yuqori.
4. Android emulator va real device'da fingerprint/face prompt ochilishini tekshirish.
5. `LaunchTheme` va `NormalTheme` bilan prompt ochilganda crash bo'lmasligini smoke test qilish.

### iOS

Fayllar:

- `ios/Runner/Info.plist`
- `ios/Runner.xcodeproj/project.pbxproj`

Ishlar:

1. `NSFaceIDUsageDescription` qo'shish:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Hisobingizga tez va xavfsiz kirish uchun Face ID ishlatiladi.</string>
```

2. Hozirgi iOS deployment target `13.0` ekanini saqlash va build bilan tekshirish.
3. Face ID/Touch ID test device'da permission prompt va cancel flow'ni tekshirish.

## Figma widget kontrakti

Yangi widget tavsiya etiladi:

```text
lib/features/auth/presentation/widgets/biometric_login_button.dart
```

Widget quyidagilarni qabul qiladi:

- `VoidCallback onPressed`;
- `bool isEnabled`;
- `bool isLoading`;
- localized `title`;
- Figma'dagi asset/icon.

Loyihadagi UI conventionlariga muvofiq:

- ranglar widget ichida raw hex bo'lib qolmasin; `AppColors` tokenlariga chiqarilsin;
- Manrope mavjud `google_fonts` orqali ishlatilsin;
- responsive o'lchamlar loyiha `size_extension.dart` conventioniga mos yozilsin;
- asset `AppTools` orqali reference qilinsin;
- Figma'dagi `20 px` radiusli tugma password login tugmasining `12 px` radiusini o'zgartirmasin.

## Localization

`Words` enum va barcha uch translation fayliga bir xil keylar qo'shiladi:

```text
biometricLogin
biometricPromptReason
biometricNotAvailable
biometricNotEnrolled
biometricLockedOut
biometricTryPassword
sessionLoginAgain
```

Uzbek Latin uchun asosiy matnlar:

```json
{
  "biometricLogin": "Barmoq izi yo’ki FaceID orqali",
  "biometricPromptReason": "Hisobingizga kirishni tasdiqlang",
  "biometricNotAvailable": "Biometrik kirish mavjud emas",
  "biometricNotEnrolled": "Qurilmada biometrika sozlanmagan",
  "biometricLockedOut": "Biometrik kirish vaqtincha bloklandi",
  "biometricTryPassword": "Login va parol orqali davom eting",
  "sessionLoginAgain": "Sessiya tugagan. Qayta login qiling"
}
```

Russian va Uzbek Cyrillic tarjimalari ham bir commit'da qo'shiladi. Foydalanuvchiga ko'rinadigan matnlar widget ichida hardcode qilinmaydi.

## Error va fallback qoidalari

| Holat | Natija |
| --- | --- |
| Qurilma biometricani qo'llamaydi | Button yashiriladi, password login qoladi |
| Biometrika enrolled emas | Button yashiriladi yoki unavailable state; password login qoladi |
| User cancel | LoginScreen'da qoladi, error shart emas |
| Noto'g'ri biometric | Qisqa xabar va password fallback |
| Temporary/permanent lockout | `biometricLockedOut`, password fallback |
| System prompt unavailable | Log + umumiy xabar, password fallback |
| Ikkinchi tap/auth in progress | Yangi prompt ochilmaydi |
| Biometric success, token yo'q | LoginScreen'ga qaytadi; password talab qilinadi |
| Biometric success, token bor | Shared post-auth gate orqali Agreement yoki Home |
| Token access expired | Mavjud API refresh oqimi ishlaydi; refresh ham yiqilsa token tozalanib login so'raladi |
| Explicit logoutdan keyin | Token yo'q, biometric button va auto prompt ishlamaydi |

Biometric local success server sessiya yaroqli ekanini kafolatlamaydi. Shu sababli access/refresh token yo'qolganda yoki refresh muvaffaqiyatsiz bo'lganda LoginScreen'ga xavfsiz qaytish kerak.

## Security qarorlari

- Password va PIN saqlanmaydi.
- `local_auth` faqat lokal qurilma tasdig'ini beradi.
- Biometric success yangi backend token yaratmaydi.
- Tokenli session soft lock'da saqlanadi, explicit logout'da hard clear qilinadi.
- `last_active_millis` biometric yoki password login success'dan keyin yangilanadi.
- Auto prompt bir entry uchun bir marta ishlaydi; cancel loop bo'lmaydi.
- Mavjud Hive token storage secure storage darajasida emas. Bu plan uni migratsiya qilmaydi, lekin keyingi security task sifatida belgilaydi.

## Implementation bosqichlari

### Bosqich 1 - Contract va platform audit

- `local_auth ^2.3.0` API'sini current Flutter SDK bilan tekshirish.
- `MainActivity`, Android manifest, minSdk va iOS Info.plist'ni tayyorlash.
- `ApiHive.clear()` va `clearAll()` ishlatiladigan barcha logout/relogin joylarini ro'yxatga olish.
- `SplashScreen` va `main.dart` lifecycle qarorlarini yakunlash.

### Bosqich 2 - Biometric service va DI

- Domain enum/interface yaratish.
- `LocalAuthentication` wrapper implementatsiyasi.
- Exception mapping va fake qilinadigan platform abstraction yozish.
- Injectable registration qo'shish.
- `dart run build_runner build --delete-conflicting-outputs` bilan generated DI faylni yangilash.

### Bosqich 3 - LoginBloc va session restore

- Biometric event/state qo'shish.
- Stored session contract/use case qo'shish.
- Success'dan keyin `last_active_millis` yangilash.
- Token yo'q holatda login fallback'ni saqlash.
- Password va biometric uchun shared post-auth handler ajratish.

### Bosqich 4 - LoginScreen va Figma UI

- `biometric_login_button.dart` yaratish.
- `LoginScreen(autoBiometric: ...)` entry mode qo'shish.
- Availability bo'yicha buttonni shartli ko'rsatish.
- Buttonni `Kirish` ostiga Figma o'lcham va style'lari bilan joylash.
- Auto prompt'ni `initState`da, UI frame qurilgandan keyin va faqat bir marta ishga tushirish.
- Prompt in progress va fallback state'larini UI'da ko'rsatish.

### Bosqich 5 - Splash, lifecycle va logout

- Cold start'da tokenli returning user'ni `LoginScreen(autoBiometric: true)`ga yuborish.
- Timeout'da auto biometric, `pendingRelogin`da mavjud full-login qarorini saqlash.
- Explicit logout barcha tokenlarni tozalashini kafolatlash.
- Biometric success'dan keyin shared attendance gate'ni chaqirish.

### Bosqich 6 - Localization, tests va verification

- Uch locale uchun yangi keylarni qo'shish.
- Unit/widget/BLoC testlarini yozish.
- `flutter test` va `flutter analyze`ni ishga tushirish.
- Android/iOS real-device smoke test qilish.
- Figma screenshot bilan buttonni vizual solishtirish.

## Test scenariylari

### Unit/BLoC

1. Device unsupported bo'lsa `notSupported` qaytadi.
2. Device supported, biometric enrolled emas bo'lsa `notEnrolled` qaytadi.
3. Successful biometric stored token bor holatda unlock success beradi.
4. Stored token yo'q holatda biometric success protected navigation boshlamaydi.
5. Cancel/failed/lockout holatlarida password fallback state saqlanadi.
6. Ikki marta tez yuborilgan request bitta system prompt bilan cheklanadi.
7. Logoutdan keyin `hasStoredSession == false` bo'ladi.
8. Auto prompt faqat `autoBiometric == true` va availability `available` bo'lganda yuboriladi.

### Widget

1. Token yo'q bo'lsa biometric button ko'rinmaydi.
2. Token va enrolled biometric bor bo'lsa button `Kirish` ostida ko'rinadi.
3. Button Figma label va iconni ko'rsatadi.
4. Prompt in progress'da button va password login double-tapdan himoyalanadi.
5. Cancel'dan keyin username/password formasi qayta ishlaydi.
6. Biometric success password login kabi attendance gate'ga o'tadi.

### Real device

#### Android

- fingerprint enrolled device'da button va auto prompt;
- face unlock mavjud device'da prompt;
- cancel, noto'g'ri urinish va lockout;
- app cold start, background timeout va normal quick resume;
- explicit logoutdan keyin button/prompt yo'qligi;
- refresh token yaroqli va yaroqsiz holatlar.

#### iOS

- Face ID permission va prompt;
- Touch ID qurilmada fallback;
- cancel va system interruption;
- cold start auto prompt;
- explicit logoutdan keyin full login;
- access/refresh token yo'q holat.

## Acceptance criteria

Funksiya tugallangan hisoblanadi, agar:

- Birinchi login username/password bilan odatdagidek ishlasa.
- Returning user token mavjud bo'lsa LoginScreen'da biometric button ko'rinsa.
- Figma node `631:7601` style'lari bilan mos button ishlasa.
- Ilova qayta ochilganda auto biometric prompt bir marta chiqsa.
- Successful biometric password login endpointini chaqirmasdan mavjud session bilan protected oqimga o'tsa.
- Attendance qoidasi buzilmasa: `AgreementPdfScreen` yoki `HomeScreen` mavjud natija bo'yicha ochilsa.
- Cancel, fail, lockout va unavailable holatlarida password fallback ishlasa.
- Token yo'q yoki refresh yaroqsiz bo'lsa LoginScreen'ga qaytilsa.
- Explicit logoutdan keyin biometric unlock ishlamasa.
- Android va iOS platform konfiguratsiyasi build'dan o'tsa.
- `flutter test` tegishli testlar bilan o'tsa va `flutter analyze` baseline'dan yangi error qo'shmasa.

## Yakuniy qarorlar

1. PIN page yoki yangi `SessionBloc` kiritilmaydi; mavjud `LoginScreen`, `LoginBloc` va lifecycle oqimi kengaytiriladi.
2. Biometric button faqat stored auth session va enrolled biometric mavjud bo'lganda ko'rsatiladi.
3. Auto biometric cold start va session timeout'da ishlaydi; normal quick resume'da ortiqcha prompt chiqmaydi.
4. Biometric success mavjud attendance gate orqali o'tadi, to'g'ridan-to'g'ri business qoidalarni chetlab o'tmaydi.
5. Explicit logout hard clear qiladi; saved username qoldirilishi mumkin, lekin token va biometric unlock eligibility qolmaydi.
6. `local_auth` dependency allaqachon mavjudligi sababli dependency qo'shish emas, platform setup va feature integration asosiy ish hisoblanadi.

