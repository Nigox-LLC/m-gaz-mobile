import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/features/auth/data/models/eimzo_mobile_session_model.dart';
import 'package:m_gaz/features/auth/data/models/eimzo_status_model.dart';

void main() {
  test('maps E-Imzo challange field to challenge', () {
    final session = EImzoMobileSessionModel.fromJson(const {
      'status': 1,
      'siteId': 'b552',
      'documentId': '362811E9',
      'challange': '59FC8CDAF823211E15F9EEB62B1CB6E1',
      'ttl': 120,
    });

    expect(session.siteId, 'b552');
    expect(session.documentId, '362811E9');
    expect(session.challenge, '59FC8CDAF823211E15F9EEB62B1CB6E1');
    expect(session.ttl, const Duration(seconds: 120));
  });

  test('maps a pending E-Imzo status', () {
    final status = EImzoStatusModel.fromJson(const {
      'status': 2,
      'message': '',
    });

    expect(status.isWaiting, isTrue);
    expect(status.isCompleted, isFalse);
  });
}
