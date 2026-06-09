import 'package:flutter/widgets.dart';

/// Sessiya/lifecycle sozlamalari uchun yagona manba.
///
/// Ilova orqa fonda shu muddatdan ko'p turib qaytsa, login majburlanadi.
/// `main.dart` (lifecycle) va `splash_screen.dart` (cold start) bir xil qiymatdan
/// foydalanadi — qiymat ikki joyda ayri yozilib chalkashmasligi uchun.
const Duration kSessionTimeout = Duration(minutes: 5);

/// Ilova haqiqatan orqa fonga o'tganini bildiruvchi yagona signal.
///
/// FAQAT `paused`. `hidden` ishonchsiz — u orqa fonga o'tishda ham, foreground'ga
/// qaytishda ham yuboriladi (to'liq ketma-ketlik: `inactive → hidden → paused`
/// orqa fon; `paused → hidden → inactive → resumed` qaytish). Agar `hidden`'ni
/// ham orqa fon deb hisoblasak, qaytish paytida sessiya taymeri qayta yozilib,
/// 30 soniyalik timeout (ayniqsa Home tugmasi yo'li) hech qachon ishlamaydi.
bool isAppBackgrounded(AppLifecycleState state) =>
    state == AppLifecycleState.paused;
