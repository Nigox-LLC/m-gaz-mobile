import 'package:equatable/equatable.dart';

class ConsumerHourlyFile extends Equatable {
  final String file;

  const ConsumerHourlyFile({
    required this.file,
  });

  factory ConsumerHourlyFile.fromJson(Map<String, dynamic> json) {
    return ConsumerHourlyFile(
      file: json['file'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
    };
  }

  @override
  List<Object?> get props => [file];
}