import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/features/auth/domain/entities/user.dart';

void main() {
  test('requires a profile photo only when the URL is absent', () {
    const withoutPhoto = User(id: 1, username: 'tester', role: 'employee');
    const withBlankPhoto = User(
      id: 1,
      username: 'tester',
      role: 'employee',
      photoUrl: '  ',
    );
    const withPhoto = User(
      id: 1,
      username: 'tester',
      role: 'employee',
      photoUrl: 'https://example.com/profile.jpg',
    );

    expect(withoutPhoto.hasProfilePhoto, isFalse);
    expect(withBlankPhoto.hasProfilePhoto, isFalse);
    expect(withPhoto.hasProfilePhoto, isTrue);
  });
}
