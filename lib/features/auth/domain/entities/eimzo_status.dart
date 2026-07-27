import 'package:equatable/equatable.dart';

class EImzoStatus extends Equatable {
  const EImzoStatus({required this.code, this.message = ''});

  final int code;
  final String message;

  bool get isCompleted => code == 1;
  bool get isWaiting => code == 2;

  @override
  List<Object?> get props => [code, message];
}
