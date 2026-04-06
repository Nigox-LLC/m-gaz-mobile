class LoginModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;

  const LoginModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
  });

  factory LoginModel.initial() =>
      const LoginModel(firstName: '', lastName: '', phone: '', password: '');

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      phone: json['phone_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phone,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
    };
  }
}
