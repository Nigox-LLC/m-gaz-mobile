class TokenModel {
  String refresh;
  String access;

  TokenModel({required this.refresh, required this.access});

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      TokenModel(refresh: json["refresh"] ?? "", access: json["access"] ?? "");

  Map<String, dynamic> toJson() => {"refresh": refresh, "access": access};
}
