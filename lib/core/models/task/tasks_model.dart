class TaskModel {
  final int id;
  final String employee;
  final String? typeTask;
  final String status;
  final String situation;
  final String description;

  final DateTime? deadline;
  final DateTime? doneDate;
  final DateTime? approvedDate;
  final DateTime? canceledDate;
  final DateTime created;

  final bool isDone;
  final bool isApproved;
  final bool isCanceled;
  final bool isAnswerFile;

  final ConsumerDocument? consumerDocument;

  TaskModel({
    required this.id,
    required this.employee,
    required this.typeTask,
    required this.status,
    required this.situation,
    required this.description,
    required this.deadline,
    required this.doneDate,
    required this.approvedDate,
    required this.canceledDate,
    required this.created,
    required this.isDone,
    required this.isApproved,
    required this.isCanceled,
    required this.isAnswerFile,
    required this.consumerDocument,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: _readInt(json['id']),
      employee: _readDisplayText(json['employee']),
      typeTask: _readNullableDisplayText(json['type_task']),
      status: _readDisplayText(json['status']),
      situation: _readDisplayText(json['situation']),
      description: _readDisplayText(json['description']),

      deadline: json['deadline'] == null
          ? null
          : DateTime.tryParse(json['deadline'].toString()),

      doneDate: json['done_date'] == null
          ? null
          : DateTime.tryParse(json['done_date'].toString()),

      approvedDate: json['approved_date'] == null
          ? null
          : DateTime.tryParse(json['approved_date'].toString()),

      canceledDate: json['canceled_date'] == null
          ? null
          : DateTime.tryParse(json['canceled_date'].toString()),

      created:
          DateTime.tryParse(json['created']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      isDone: _readBool(json['is_done']),
      isApproved: _readBool(json['is_approved']),
      isCanceled: _readBool(json['is_canceled']),
      isAnswerFile: _readBool(json['is_answer_file']),

      consumerDocument: _readConsumerDocument(
        json['consumer_docment'] ?? json['consumer_document'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee': employee,
      'type_task': typeTask,
      'status': status,
      'situation': situation,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'done_date': doneDate?.toIso8601String(),
      'approved_date': approvedDate?.toIso8601String(),
      'canceled_date': canceledDate?.toIso8601String(),
      'created': created.toIso8601String(),
      'is_done': isDone,
      'is_approved': isApproved,
      'is_canceled': isCanceled,
      'is_answer_file': isAnswerFile,
      'consumer_docment': consumerDocument?.toJson(),
    };
  }
}

class ConsumerDocument {
  final int documentId;
  final String documentName;
  final int documentFacial;

  ConsumerDocument({required this.documentId, required this.documentName, required this.documentFacial});

  factory ConsumerDocument.fromJson(Map<String, dynamic> json) {
    return ConsumerDocument(
      documentId: _readInt(json['document_id']),
      documentName: _readDisplayText(json['document_name']),
      documentFacial: _readInt(json['document_facial']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'document_id': documentId, 'document_name': documentName, 'document_facial': documentFacial};
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().toLowerCase().trim();
  return normalized == 'true' || normalized == '1';
}

ConsumerDocument? _readConsumerDocument(Object? value) {
  if (value is Map) {
    return ConsumerDocument.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

String? _readNullableDisplayText(Object? value) {
  final text = _readDisplayText(value).trim();
  return text.isEmpty ? null : text;
}

String _readDisplayText(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    for (final key in const [
      'fio',
      'full_name',
      'username',
      'name',
      'title',
      'display_name',
      'label',
    ]) {
      final nestedValue = value[key];
      if (nestedValue != null && nestedValue.toString().trim().isNotEmpty) {
        return nestedValue.toString();
      }
    }
    return '';
  }
  return value.toString();
}
