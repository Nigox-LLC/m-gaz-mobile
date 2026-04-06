import 'package:equatable/equatable.dart';

class TeachMeasureIndicatorImage extends Equatable {
  final int id;
  final String? image;
  final bool isActive;

  const TeachMeasureIndicatorImage({
    required this.id,
    this.image,
    required this.isActive,
  });

  factory TeachMeasureIndicatorImage.fromJson(Map<String, dynamic> json) {
    return TeachMeasureIndicatorImage(
      id: json['id'] as int,
      image: json['image'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, image, isActive];
}