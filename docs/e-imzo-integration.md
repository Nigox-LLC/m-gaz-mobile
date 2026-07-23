# M-GAZ Flutter ilovasiga E-IMZO integratsiyasi

Holat: 2026-07-23

Bu hujjat uchta manba asosida tuzildi:

- [E-IMZO rasmiy integratsiya README](https://github.com/qo0p/e-imzo-doc/blob/master/README.md)
- [M-GAZ Swagger UI](https://backend.m-gaz.uz/api/docs/)
- [M-GAZ OpenAPI schema](https://backend.m-gaz.uz/api/schema/)

## 1. Qisqa xulosa

`m-gaz-mobile` Flutter mobil ilova. Shu sababli brauzer uchun mo‘ljallangan `E-IMZO.exe`, `CAPIWS`, `list_all_keys()`, `load_key()` oqimi bu loyihaga mos emas. Mobil yo‘l — foydalanuvchi telefonidagi **E-IMZO ID-CARD** ilovasini `eimzo://sign?qc=...` deeplink orqali ochish, keyin E-IMZO serverdagi statusni polling qilish.

M-GAZ backend’da hozir ikki endpoint e’lon qilingan:

| Maqsad | Method | URL | Auth |
|---|---:|---|---|
| E-IMZO orqali autentifikatsiya | POST | `/api/e-imzo/auth/e-imzo/` | `Bearer` ixtiyoriy ko‘rsatilgan |
| Hujjatni E-IMZO orqali imzolash | POST | `/api/e-imzo/documents/sign/` | `Bearer` majburiy ko‘rsatilgan |

OpenAPI’dagi ushbu ikki operatsiyada request body va response schema yo‘q. `OPTIONS` endpoint JSON, `application/x-www-form-urlencoded` va multipart parserlarni qabul qilishini ko‘rsatadi; bo‘sh `POST` 400 qaytardi. Demak, field nomlari va muvaffaqiyatli javob formati backend jamoasidan tasdiqlanmaguncha kodga taxminiy kontrakt kiritilmasin.

## 2. E-IMZO oqimi

### 2.1. Mobil autentifikatsiya

README’dagi mobil oqim:

```text
Flutter -> E-IMZO server: mobile/auth
E-IMZO server -> Flutter: siteId, documentId, challenge
Flutter: GOST hash(challenge) hisoblaydi
Flutter: CRC32 bilan deeplink yaratadi
Flutter -> E-IMZO ID-CARD: eimzo://sign?qc=...
Foydalanuvchi: ID-karta + PIN orqali imzolaydi
Flutter -> E-IMZO server: mobile/status(documentId), polling
E-IMZO server: status = 1
Flutter -> M-GAZ backend: autentifikatsiya natijasini yakunlaydi
M-GAZ backend: sertifikatni tekshiradi va o‘z JWT/sessionini beradi
```

README’dagi deeplink formulasi:

```text
code = siteId + documentId + GOST_HASH(challenge)
code = code + CRC32_HEX(code)
deeplink = eimzo://sign?qc=<code>
```

README’da `challange` yozilishi uchraydi; ilovada ichki nom sifatida `challenge` ishlatish kerak. API javobidan qiymatni mapping qatlamida o‘girish mumkin.

### 2.2. Mobil hujjat imzolash

```text
Flutter -> E-IMZO server: mobile/sign
E-IMZO server -> Flutter: siteId, documentId
Flutter: hujjatning kerakli hash qiymatini hisoblaydi
Flutter -> E-IMZO ID-CARD: eimzo://sign?qc=...
Foydalanuvchi: PIN bilan tasdiqlaydi
Flutter -> E-IMZO server: mobile/status(documentId), polling
Flutter -> M-GAZ backend: sign endpointiga documentId + yakuniy imzo ma’lumoti
M-GAZ backend: imzoni tekshiradi, hujjatni saqlaydi
```

Muhim: M-GAZ OpenAPI faqat yuqoridagi ikki backend endpointini ko‘rsatadi. README’dagi `/frontend/mobile/auth`, `/frontend/mobile/sign`, `/frontend/mobile/status` endpointlari M-GAZ API schema’da yo‘q. Ular mobil ilovaga ochiq proxy sifatida beriladimi yoki M-GAZ backend ichida yashirilganmi — backend bilan aniqlash kerak.

## 3. M-GAZ API bo‘yicha aniqlangan ma’lumot

### 3.1. `/api/e-imzo/auth/e-imzo/`

- `POST`.
- OpenAPI operation ID: `e_imzo_auth_e_imzo_create`.
- `jwtAuth` security bilan birga anonymous security ham ko‘rsatilgan (`{}`). Bu login qilish uchun endpoint bo‘lishi mumkin, lekin bu xulosa backend implementatsiyasi tasdig‘isiz yakuniy kontrakt emas.
- Request body schema ko‘rsatilmagan.
- Response body schema ko‘rsatilmagan.
- Bo‘sh request: `400`.

Backend’dan quyidagilar yozma tasdiqlansin:

```text
1. Request body JSONmi yoki formmi?
2. Field nomi: pkcs7, documentId/document, signature yoki boshqa nommi?
3. Birinchi chaqiriq challenge yaratadimi yoki mobil auth ma’lumotini qaytaradimi?
4. Javobda siteId, documentId, challenge, access/refresh token qaysi fieldlarda keladi?
5. E-IMZO mobile/status qaysi URL orqali chaqiriladi?
6. Status pollingdan keyin qaysi endpoint yakuniy sertifikat tekshiruvini bajaradi?
```

### 3.2. `/api/e-imzo/documents/sign/`

- `POST`.
- OpenAPI operation ID: `e_imzo_documents_sign_create`.
- `Bearer` JWT talab qilinadi.
- Request body schema ko‘rsatilmagan.
- Response body schema ko‘rsatilmagan.
- Bo‘sh request: `400`.

Backend’dan quyidagilar yozma tasdiqlansin:

```text
1. document ID qaysi fieldda yuboriladi?
2. Original document Base64, document hash yoki detached PKCS#7 yuboriladimi?
3. E-IMZO ID-CARD bergan imzo qaysi fieldda yuboriladi?
4. `pkcs7Attached`ni ilova yuboradimi yoki backend o‘zi hosil qiladimi?
5. Muvaffaqiyat javobi: status, message, pkcs7Attached, verificationInfo va signer ma’lumotlari qaysi formatda?
6. Takroriy `POST` idempotentmi? Timeoutdan keyin qayta yuborish xavfsizmi?
```

## 4. Shu loyihaga tavsiya etilgan joylashuv

Loyihadagi mavjud API qatlamidan foydalaning:

```text
lib/core/api/base/base_api.dart       ApiBase, baseUrl, Bearer interceptor
lib/core/api/e_imzo/e_imzo_api.dart   M-GAZ endpoint wrapperlari
lib/core/models/e_imzo/               DTO va response mapping
lib/core/services/e_imzo/             deeplink, hash, CRC32, polling
lib/ui/.../bloc/                      loading/success/failure state
```

Yangi HTTP dependency qo‘shish shart emas: loyihada `dio`, `url_launcher`, `flutter_bloc` bor. GOST hash va CRC32 uchun esa random yoki tekshirilmagan paket qo‘shishdan oldin backend/E-IMZO bilan bir xil test vectorlar olinishi kerak.

## 5. Bosqichma-bosqich integratsiya

### 5.1. Model

Backend kontrakti tasdiqlangach, faqat real fieldlar bilan model yarating:

```dart
class EImzoMobileSession {
  const EImzoMobileSession({
    required this.siteId,
    required this.documentId,
    this.challenge,
  });

  final String siteId;
  final String documentId;
  final String? challenge;
}
```

`challenge` auth uchun kerak; sign oqimida server qaytaradigan qiymat bo‘lmasa modelga sun’iy field qo‘shmang.

### 5.2. API wrapper

`ApiBase` allaqachon `https://backend.m-gaz.uz/api/` va `Authorization: Bearer ...` headerini boshqaradi. Shuning uchun E-IMZO API wrapper quyidagiga o‘xshash bo‘lsin:

```dart
class EImzoApi {
  const EImzoApi(this._base);

  final ApiBase _base;

  Future<Response<dynamic>> authenticate(Map<String, dynamic> body) {
    return _base.dio.post('e-imzo/auth/e-imzo/', data: body);
  }

  Future<Response<dynamic>> sign(Map<String, dynamic> body) {
    return _base.dio.post('e-imzo/documents/sign/', data: body);
  }
}
```

`body` fieldlari backend tasdiqlaganidan keyin typed request modelga almashtiriladi. Hozircha `dynamic`ni production kontrakt deb qabul qilmang; u faqat endpoint integratsiyasini bloklamaslik uchun skelet.

### 5.3. Deeplink service

Service vazifalari:

1. E-IMZO mobile session yaratish.
2. `GOST_HASH` va `CRC32_HEX` hisoblash.
3. `eimzo://sign?qc=...` URLni `url_launcher` orqali ochish.
4. `documentId` bo‘yicha 2–3 soniyalik intervalda status tekshirish.
5. Timeout, app o‘rnatilmagan, foydalanuvchi bekor qilgan va status error holatlarini ajratish.

Polling qoidasi:

```text
status = 2  -> kutish, qayta tekshirish
status = 1  -> keyingi backend verification/sign chaqirig‘i
status < 0  -> foydalanuvchiga tushunarli xato, retry imkoniyati
timeout     -> sessiyani muvaffaqiyatsiz yakunlash
```

README status polling uchun 3 soniyalik intervalga yaqin misol beradi. Production’da max timeout 90–120 soniya qilib, `Timer`ni dispose/cancel qilish kerak.

### 5.4. UI/BLoC

Mavjud BLoC uslubiga mos state’lar:

```text
initial
loading
waitingForEImzo
verifying
success
failure(message)
```

UI faqat BLoC event yuborsin. Deeplink, polling, hash va API chaqiriqlarini widget ichiga joylamang. Foydalanuvchiga quyidagi holatlar alohida ko‘rsatilsin:

- E-IMZO ID-CARD topilmadi.
- E-IMZO ilovasi ochildi, PIN kiritish kutilmoqda.
- Imzo serverga yetib kelishi kutilmoqda.
- Sertifikat yaroqsiz yoki muddati tugagan.
- Backend imzoni qabul qilmadi.

## 6. Android va iOS

### Android

Tashqi `eimzo://` URLni ochish uchun `url_launcher` yetarli. Android manifestga E-IMZO ilovasining package name’ini intent handler sifatida qo‘shish shart emas; ilova URLni qabul qiladi. Ixtiyoriy ravishda `uz.yt.idcard.eimzo` o‘rnatilganini tekshirish mumkin.

### iOS

`Info.plist` ichida tashqi scheme tekshirilsa, `LSApplicationQueriesSchemes`ga `eimzo` qo‘shiladi. Bu faqat `canLaunchUrl` uchun kerak bo‘lishi mumkin; real qurilmada E-IMZO ID-CARD bilan tekshirilsin.

### Qurilma shartlari

README mobil oqimida NFC o‘quvchi, yaroqli E-IMZO sertifikati va E-IMZO ID-CARD ilovasi kerakligi ko‘rsatilgan. Android emulator bilan to‘liq flow tekshirilmaydi.

## 7. Xavfsizlik va xatoliklar

- Private key, PIN va E-IMZO maxfiy ma’lumotlarini Flutter loglariga yozmang.
- Challenge/document hashni o‘zgartirmang; signing oldidan va keyingi verificationda aynan bir xil canonical data ishlating.
- `siteId`, `documentId`, `challenge`ni user-controlled deb hisoblang; uzunlik va bo‘sh qiymatlarni tekshiring.
- Polling tugaganidan keyin server statusini yana backend verification bilan tekshirmasdan `success` ko‘rsatmang.
- Sertifikat `validFrom`, `validTo`, revoke/OCSP va signer identity tekshiruvini backendga qoldiring.
- `pkcs7Attached`ni local storage’ga faqat kerak bo‘lsa saqlang; JWT va imzo ma’lumotlarini debug logga chiqarmang.
- Access token interceptor orqali avtomatik qo‘shiladi. Auth login endpointi anonymous bo‘lsa, `no_token` flagni faqat backend tasdig‘idan keyin ishlating.

## 8. Test rejasi

Backend kontrakti kelgach:

1. Auth endpoint uchun real request/response JSON fixture qo‘shing.
2. Sign endpoint uchun original document, hash va imzo fixturelarini qo‘shing.
3. GOST hash test vector: kirish, kutilgan hash.
4. CRC32 test vector: kirish, kutilgan uppercase hex CRC.
5. `status = 2`, `1`, `-2`, timeout va network exception testlari.
6. E-IMZO ID-CARD o‘rnatilmagan real Android qurilma testi.
7. PIN noto‘g‘ri, sertifikat muddati tugagan, internet uzilgan testlari.
8. Sign tugmasini ketma-ket bosganda duplicate request bo‘lmasligi.

Minimal acceptance flow:

```text
Login/sign bosildi
-> session olindi
-> deeplink ochildi
-> E-IMZO ID-CARD imzoni qabul qildi
-> status 1 bo‘ldi
-> backend verification/sign muvaffaqiyatli
-> UI success
```

## 9. Backend jamoasidan olinadigan yakuniy kontrakt

Integratsiyani productionga chiqarishdan oldin backend README yoki Swagger’ga quyidagi namunani qo‘shishi kerak:

```json
{
  "request": {
    "field": "real field name",
    "type": "string",
    "encoding": "base64/urlencoded/plain"
  },
  "success": {
    "status": 1,
    "message": null
  },
  "errors": [
    {"status": -10, "message": "..."}
  ]
}
```

Ayniqsa quyidagilar aniq bo‘lmasa release qilish mumkin emas: `documentId` lifecycle, hash algoritmi, deeplink uchun qaysi challenge ishlatilishi, M-GAZ endpointiga yuboriladigan imzo fieldi va polling endpointi.

## 10. Manbalar va farqlar

- E-IMZO README desktop oqimida `create_pkcs7` va PKCS#7 ishlatiladi; mobil oqimda E-IMZO ID-CARD, GOST hash, CRC32 va deeplink ishlatiladi.
- README’dagi `/backend/*` endpointlari server ichki endpointlari bo‘lishi kerak; mobil ilovaga private key yoki E-IMZO server VPN credential berilmaydi.
- M-GAZ OpenAPI hozir endpoint nomlari va security’ni ko‘rsatadi, ammo payload/response detailni ko‘rsatmaydi. Ushbu hujjat ataylab bunday joylarda taxminiy fieldlarni “aniq” deb belgilamadi.

