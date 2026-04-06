import 'package:equatable/equatable.dart';

class ConsumerIndicatorImage extends Equatable {
  final String image;

  const ConsumerIndicatorImage({
    required this.image,
  });

  factory ConsumerIndicatorImage.fromJson(Map<String, dynamic> json) {
    return ConsumerIndicatorImage(
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
    };
  }

  @override
  List<Object?> get props => [image];
}