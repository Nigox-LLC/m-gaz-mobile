import 'package:equatable/equatable.dart';

class EImzoMobileSession extends Equatable {
  const EImzoMobileSession({
    required this.siteId,
    required this.documentId,
    required this.challenge,
    required this.ttl,
  });

  final String siteId;
  final String documentId;
  final String challenge;
  final Duration ttl;

  @override
  List<Object?> get props => [siteId, documentId, challenge, ttl];
}
