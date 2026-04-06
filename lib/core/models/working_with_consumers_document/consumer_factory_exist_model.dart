class ConsumerFactoryExistResponse {
  final bool exists;
  final List<dynamic> factories;

  ConsumerFactoryExistResponse({
    required this.exists,
    required this.factories,
  });

  factory ConsumerFactoryExistResponse.fromJson(Map<String, dynamic> json) {
    return ConsumerFactoryExistResponse(
      exists: json['exists'] ?? false,
      factories: json['factories'] ?? [],
    );
  }
}
