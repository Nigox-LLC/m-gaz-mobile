import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/user/token_model.dart';
import 'package:m_gaz/features/auth/data/models/auth_token_model.dart';

void main() {
  const loginResponse = {
    'refresh': 'refresh-token',
    'access': 'access-token',
    'user': {'id': 85, 'username': 'Toshmatov Axrorjon', 'employee_id': 110},
  };

  test('legacy token model reads employee id from login response user', () {
    final token = TokenModel.fromJson(loginResponse);

    expect(token.access, 'access-token');
    expect(token.refresh, 'refresh-token');
    expect(token.employeeId, 110);
    expect(token.toJson()['employee_id'], 110);
  });

  test('auth token model reads employee id from login response user', () {
    final token = AuthTokenModel.fromJson(loginResponse);

    expect(token.access, 'access-token');
    expect(token.refresh, 'refresh-token');
    expect(token.employeeId, 110);
    expect(token.toJson()['employee_id'], 110);
  });
}
