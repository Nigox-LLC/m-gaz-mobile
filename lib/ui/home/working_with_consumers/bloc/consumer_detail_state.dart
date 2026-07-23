import 'package:equatable/equatable.dart';

import '../../../../core/models/working_with_consumers_document/consumer_file_models.dart';
import '../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';

enum ConsumerDetailStatus { initial, loading, loaded, fail }

enum ConsumerDetailSaveStatus { idle, saving, success, failure }

/// Fayl bo'limi turi.
enum ConsumerFileSlot { certificate, technical, contract }

class ConsumerDetailState extends Equatable {
  const ConsumerDetailState({
    this.status = ConsumerDetailStatus.initial,
    this.errorMessage,
    this.document,
    this.draftDocument,
    this.companyInfoExpanded = false,
    this.expandedEgxuIds = const {},
    this.isDirty = false,
    this.certsByEgxu = const {},
    this.technicalDocs = const [],
    this.contracts = const [],
    this.pendingTechnical = const [],
    this.pendingContracts = const [],
    this.saveStatus = ConsumerDetailSaveStatus.idle,
    this.saveError,
  });

  final ConsumerDetailStatus status;
  final String? errorMessage;
  final WorkingWithConsumersDetailModel? document;
  final WorkingWithConsumersDetailModel? draftDocument;
  final bool companyInfoExpanded;
  final Set<int> expandedEgxuIds;
  final bool isDirty;

  // Mavjud (remote) fayllar
  final Map<int, List<EgxuCertificate>> certsByEgxu;
  final List<ConsumerUploadFile> technicalDocs;
  final List<ConsumerUploadFile> contracts;

  // Hali yuklanmagan (pending) fayllar
  final List<ConsumerUploadFile> pendingTechnical;
  final List<ConsumerUploadFile> pendingContracts;

  final ConsumerDetailSaveStatus saveStatus;
  final String? saveError;

  bool get isSaving => saveStatus == ConsumerDetailSaveStatus.saving;

  bool get hasPending =>
      pendingTechnical.isNotEmpty ||
      pendingContracts.isNotEmpty ||
      certsByEgxu.values.any(
        (certificates) => certificates.any(
          (certificate) =>
              certificate.files.any((file) => file.localPath != null),
        ),
      );

  bool get canSave =>
      status == ConsumerDetailStatus.loaded &&
      (hasPending || isDirty) &&
      !isSaving;

  /// EGHU uchun ko'rsatiladigan birlashgan ro'yxat (remote + pending).
  List<EgxuCertificate> certificatesFor(int egxuId) => [
    ...?certsByEgxu[egxuId],
  ];

  List<ConsumerUploadFile> get technicalAll => [
    ...technicalDocs,
    ...pendingTechnical,
  ];

  List<ConsumerUploadFile> get contractsAll => [
    ...contracts,
    ...pendingContracts,
  ];

  ConsumerDetailState copyWith({
    ConsumerDetailStatus? status,
    String? errorMessage,
    WorkingWithConsumersDetailModel? document,
    WorkingWithConsumersDetailModel? draftDocument,
    bool? companyInfoExpanded,
    Set<int>? expandedEgxuIds,
    bool? isDirty,
    Map<int, List<EgxuCertificate>>? certsByEgxu,
    List<ConsumerUploadFile>? technicalDocs,
    List<ConsumerUploadFile>? contracts,
    List<ConsumerUploadFile>? pendingTechnical,
    List<ConsumerUploadFile>? pendingContracts,
    ConsumerDetailSaveStatus? saveStatus,
    String? saveError,
  }) {
    return ConsumerDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      document: document ?? this.document,
      draftDocument: draftDocument ?? this.draftDocument,
      companyInfoExpanded: companyInfoExpanded ?? this.companyInfoExpanded,
      expandedEgxuIds: expandedEgxuIds ?? this.expandedEgxuIds,
      isDirty: isDirty ?? this.isDirty,
      certsByEgxu: certsByEgxu ?? this.certsByEgxu,
      technicalDocs: technicalDocs ?? this.technicalDocs,
      contracts: contracts ?? this.contracts,
      pendingTechnical: pendingTechnical ?? this.pendingTechnical,
      pendingContracts: pendingContracts ?? this.pendingContracts,
      saveStatus: saveStatus ?? this.saveStatus,
      saveError: saveError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    document,
    draftDocument,
    companyInfoExpanded,
    expandedEgxuIds,
    isDirty,
    certsByEgxu,
    technicalDocs,
    contracts,
    pendingTechnical,
    pendingContracts,
    saveStatus,
    saveError,
  ];
}
