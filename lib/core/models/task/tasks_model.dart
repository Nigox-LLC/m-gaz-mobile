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
      id: json['id'] ?? 0,
      employee: json['employee'] ?? '',
      typeTask: json['type_task'],
      status: json['status'] ?? '',
      situation: json['situation'] ?? '',
      description: json['description'] ?? '',

      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline']),

      doneDate: json['done_date'] == null
          ? null
          : DateTime.parse(json['done_date']),

      approvedDate: json['approved_date'] == null
          ? null
          : DateTime.parse(json['approved_date']),

      canceledDate: json['canceled_date'] == null
          ? null
          : DateTime.parse(json['canceled_date']),

      created: DateTime.parse(json['created']),

      isDone: json['is_done'] ?? false,
      isApproved: json['is_approved'] ?? false,
      isCanceled: json['is_canceled'] ?? false,
      isAnswerFile: json['is_answer_file'] ?? false,

      consumerDocument: json['consumer_docment'] == null
          ? null
          : ConsumerDocument.fromJson(json['consumer_docment']),
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

  ConsumerDocument({
    required this.documentId,
    required this.documentName,
  });

  factory ConsumerDocument.fromJson(Map<String, dynamic> json) {
    return ConsumerDocument(
      documentId: json['document_id'] ?? 0,
      documentName: json['document_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'document_name': documentName,
    };
  }
}
