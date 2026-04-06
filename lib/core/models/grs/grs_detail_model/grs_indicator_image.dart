class GrsIndicatorImage {
  final int? id;
  final String? image;
  final bool? isActive;

  GrsIndicatorImage({this.id, this.image, this.isActive});

  factory GrsIndicatorImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsIndicatorImage();
    return GrsIndicatorImage(id: json['id'], image: json['image'], isActive: json['is_active']);
  }
}