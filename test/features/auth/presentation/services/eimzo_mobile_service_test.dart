import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/features/auth/domain/entities/eimzo_mobile_session.dart';
import 'package:m_gaz/features/auth/domain/entities/eimzo_status.dart';
import 'package:m_gaz/features/auth/presentation/services/eimzo_mobile_service.dart';

void main() {
  const session = EImzoMobileSession(
    siteId: 'b552',
    documentId: '362811E9',
    challenge: 'abc',
    ttl: Duration(seconds: 120),
  );

  test('builds the official E-Imzo qc deeplink', () {
    final deeplink = EImzoMobileService().buildDeepLink(session);

    expect(
      deeplink,
      'eimzo://sign?qc='
      'b552362811E9'
      'b285056dbf18d7392d7677369524dd14747459ed8143997e163b2986f92fd42c'
      '33d4ad61',
    );
    expect(Uri.parse(deeplink).queryParameters['qc'], hasLength(84));
  });

  test('can wait for the initial status 2 before launching E-Imzo', () async {
    final status = await EImzoMobileService().waitForCompletion(
      session: session,
      stopWhenWaiting: true,
      getStatus: (_) async => const EImzoStatus(code: 2),
    );

    expect(status.isWaiting, isTrue);
  });
}
