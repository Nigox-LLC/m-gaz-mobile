import '../../domain/entities/eimzo_mobile_session.dart';

class EImzoMobileSessionModel extends EImzoMobileSession {
  const EImzoMobileSessionModel({
    required super.siteId,
    required super.documentId,
    required super.challenge,
    required super.ttl,
  });

  factory EImzoMobileSessionModel.fromJson(Map<String, dynamic> json) {
    final status = _asInt(json['status']);
    final siteId = json['siteId']?.toString() ?? '';
    final documentId = json['documentId']?.toString() ?? '';
    // E-Imzo returns the misspelled `challange` field.
    final challenge =
        (json['challange'] ?? json['challenge'])?.toString() ?? '';
    final ttlSeconds = _asInt(json['ttl']);

    if (status != 1 ||
        siteId.isEmpty ||
        documentId.isEmpty ||
        challenge.isEmpty) {
      throw const FormatException('E-Imzo session response is invalid.');
    }

    return EImzoMobileSessionModel(
      siteId: siteId,
      documentId: documentId,
      challenge: challenge,
      ttl: Duration(seconds: ttlSeconds > 0 ? ttlSeconds : 120),
    );
  }

  static int _asInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
