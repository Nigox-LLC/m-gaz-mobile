import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../core/models/working_with_consumers_document/consumer_file_models.dart';
import '../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../di.dart';
import 'consumer_detail_state.dart';

part 'consumer_detail_event.dart';

class ConsumerDetailBloc
    extends Bloc<ConsumerDetailEvent, ConsumerDetailState> {
  final ConsumerRelationsApi _api;

  ConsumerDetailBloc({ConsumerRelationsApi? api})
    : _api = api ?? di.get<ConsumerRelationsApi>(),
      super(const ConsumerDetailState()) {
    on<ConsumerDetailFetched>(_onFetched);
    on<ConsumerDetailCompanyToggled>(_onCompanyToggled);
    on<ConsumerDetailEgxuToggled>(_onEgxuToggled);
    on<ConsumerDetailCompanyChanged>(_onCompanyChanged);
    on<ConsumerDetailEgxuRelationChanged>(_onEgxuRelationChanged);
    on<ConsumerDetailEgxuItemChanged>(_onEgxuItemChanged);
    on<ConsumerDetailFileAdded>(_onFileAdded);
    on<ConsumerDetailFileRemoved>(_onFileRemoved);
    on<ConsumerDetailCertificateAdded>(_onCertificateAdded);
    on<ConsumerDetailCertificateChanged>(_onCertificateChanged);
    on<ConsumerDetailCertificateFileAdded>(_onCertificateFileAdded);
    on<ConsumerDetailCertificateFileRemoved>(_onCertificateFileRemoved);
    on<ConsumerDetailSaved>(_onSaved);
  }

  Future<void> _onFetched(
    ConsumerDetailFetched event,
    Emitter<ConsumerDetailState> emit,
  ) async {
    emit(const ConsumerDetailState(status: ConsumerDetailStatus.loading));

    try {
      final document = await _api.getDocumentById(event.documentId);
      final files = await _loadRemoteFiles(document);

      emit(
        ConsumerDetailState(
          status: ConsumerDetailStatus.loaded,
          document: document,
          draftDocument: document,
          certsByEgxu: files.certsByEgxu,
          technicalDocs: files.technical,
          contracts: files.contracts,
        ),
      );
    } catch (e) {
      emit(
        ConsumerDetailState(
          status: ConsumerDetailStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onCompanyToggled(
    ConsumerDetailCompanyToggled event,
    Emitter<ConsumerDetailState> emit,
  ) {
    emit(state.copyWith(companyInfoExpanded: !state.companyInfoExpanded));
  }

  void _onEgxuToggled(
    ConsumerDetailEgxuToggled event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final expanded = Set<int>.from(state.expandedEgxuIds);
    if (!expanded.add(event.egxuId)) {
      expanded.remove(event.egxuId);
    }
    emit(state.copyWith(expandedEgxuIds: expanded));
  }

  void _onCompanyChanged(
    ConsumerDetailCompanyChanged event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final draft = state.draftDocument;
    final egxuList = draft?.egxuList;
    if (draft == null || egxuList == null) return;

    emit(
      state.copyWith(
        draftDocument: draft.copyWith(
          egxuList: egxuList
              .map(
                (item) => item.companyInfo == null
                    ? item
                    : item.copyWith(companyInfo: event.companyInfo),
              )
              .toList(),
        ),
        isDirty: true,
        saveStatus: ConsumerDetailSaveStatus.idle,
      ),
    );
  }

  void _onEgxuRelationChanged(
    ConsumerDetailEgxuRelationChanged event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final draft = state.draftDocument;
    final egxuList = draft?.egxuList;
    if (draft == null || egxuList == null) return;

    emit(
      state.copyWith(
        draftDocument: draft.copyWith(
          egxuList: egxuList
              .map(
                (item) => item.id == event.egxuId
                    ? item.copyWith(consumerRelationEgxu: event.relation)
                    : item,
              )
              .toList(),
        ),
        isDirty: true,
        saveStatus: ConsumerDetailSaveStatus.idle,
      ),
    );
  }

  void _onEgxuItemChanged(
    ConsumerDetailEgxuItemChanged event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final draft = state.draftDocument;
    final egxuList = draft?.egxuList;
    final itemId = event.item.id;
    if (draft == null || egxuList == null || itemId == null) return;

    emit(
      state.copyWith(
        draftDocument: draft.copyWith(
          egxuList: egxuList
              .map((item) => item.id == itemId ? event.item : item)
              .toList(),
        ),
        isDirty: true,
        saveStatus: ConsumerDetailSaveStatus.idle,
      ),
    );
  }

  void _onFileAdded(
    ConsumerDetailFileAdded event,
    Emitter<ConsumerDetailState> emit,
  ) {
    switch (event.slot) {
      case ConsumerFileSlot.certificate:
        break;
      case ConsumerFileSlot.technical:
        emit(
          state.copyWith(
            pendingTechnical: [...state.pendingTechnical, event.file],
            saveStatus: ConsumerDetailSaveStatus.idle,
          ),
        );
        break;
      case ConsumerFileSlot.contract:
        emit(
          state.copyWith(
            pendingContracts: [...state.pendingContracts, event.file],
            saveStatus: ConsumerDetailSaveStatus.idle,
          ),
        );
        break;
    }
  }

  void _onFileRemoved(
    ConsumerDetailFileRemoved event,
    Emitter<ConsumerDetailState> emit,
  ) {
    switch (event.slot) {
      case ConsumerFileSlot.certificate:
        break;
      case ConsumerFileSlot.technical:
        emit(
          state.copyWith(
            pendingTechnical: state.pendingTechnical
                .where((f) => f != event.file)
                .toList(),
          ),
        );
        break;
      case ConsumerFileSlot.contract:
        emit(
          state.copyWith(
            pendingContracts: state.pendingContracts
                .where((f) => f != event.file)
                .toList(),
          ),
        );
        break;
    }
  }

  void _onCertificateAdded(
    ConsumerDetailCertificateAdded event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final map = _copyCertificates(state.certsByEgxu);
    map[event.egxuId] = [...?map[event.egxuId], EgxuCertificate.draft()];
    emit(
      state.copyWith(
        certsByEgxu: map,
        isDirty: true,
        saveStatus: ConsumerDetailSaveStatus.idle,
      ),
    );
  }

  void _onCertificateChanged(
    ConsumerDetailCertificateChanged event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final map = _copyCertificates(state.certsByEgxu);
    final certificates = map[event.egxuId];
    if (certificates == null) return;

    map[event.egxuId] = _replaceCertificate(certificates, event.certificate);
    emit(_certificateState(state, map));
  }

  void _onCertificateFileAdded(
    ConsumerDetailCertificateFileAdded event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final map = _copyCertificates(state.certsByEgxu);
    final certificates = map[event.egxuId];
    if (certificates == null) return;
    final certificate = _findCertificate(certificates, event.certificate);
    if (certificate == null) return;
    final updated = certificate.copyWith(
      files: [...certificate.files, event.file],
    );
    map[event.egxuId] = _replaceCertificate(certificates, updated);
    emit(_certificateState(state, map));
  }

  void _onCertificateFileRemoved(
    ConsumerDetailCertificateFileRemoved event,
    Emitter<ConsumerDetailState> emit,
  ) {
    final map = _copyCertificates(state.certsByEgxu);
    final certificates = map[event.egxuId];
    if (certificates == null) return;
    final certificate = _findCertificate(certificates, event.certificate);
    if (certificate == null || event.file.isRemote) return;
    final updated = certificate.copyWith(
      files: certificate.files.where((file) => file != event.file).toList(),
    );
    map[event.egxuId] = _replaceCertificate(certificates, updated);
    emit(_certificateState(state, map));
  }

  ConsumerDetailState _certificateState(
    ConsumerDetailState current,
    Map<int, List<EgxuCertificate>> map,
  ) {
    final draft = current.draftDocument;
    return current.copyWith(
      certsByEgxu: map,
      draftDocument: draft == null
          ? null
          : _documentWithCertificates(draft, map, includeEmpty: true),
      isDirty: true,
      saveStatus: ConsumerDetailSaveStatus.idle,
    );
  }

  Future<void> _onSaved(
    ConsumerDetailSaved event,
    Emitter<ConsumerDetailState> emit,
  ) async {
    final document = state.draftDocument ?? state.document;
    if (document == null) return;
    final patchDocument = _documentWithCertificates(
      document,
      state.certsByEgxu,
      includeEmpty: false,
    );
    final hasDocumentChanges = _hasDocumentChangesAgainst(
      state.document,
      patchDocument,
    );
    final certificatesNeedPatch = _certificatesNeedPatch(state);
    if (!state.hasPending && !hasDocumentChanges && !certificatesNeedPatch) {
      return;
    }

    emit(state.copyWith(saveStatus: ConsumerDetailSaveStatus.saving));

    try {
      var savedDocument = document;
      final documentId = document.id;

      if (documentId != null && (hasDocumentChanges || certificatesNeedPatch)) {
        savedDocument = await _api.patchDocument(
          id: documentId,
          document: patchDocument,
        );
      }

      // Avval PATCH orqali yangi sertifikat ID larini olamiz, keyin fayllarni yuboramiz.
      var certificatesAfterPatch = _certificatesFromDocument(savedDocument);
      final needsCertificateRefresh = state.certsByEgxu.entries.any((entry) {
        final response = certificatesAfterPatch[entry.key];
        return entry.value.asMap().entries.any(
          (item) =>
              item.value.id == null &&
              (item.value.hasMetadata || item.value.files.isNotEmpty) &&
              _resolveCertificateId(response, item.key) == null,
        );
      });
      if (needsCertificateRefresh) {
        final refreshed = savedDocument.id == null
            ? savedDocument
            : await _api.getDocumentById(savedDocument.id!);
        certificatesAfterPatch = _certificatesFromDocument(refreshed);
      }
      for (final entry in state.certsByEgxu.entries) {
        final egxuId = entry.key;
        for (
          var certificateIndex = 0;
          certificateIndex < entry.value.length;
          certificateIndex++
        ) {
          final certificate = entry.value[certificateIndex];
          final paths = certificate.files
              .map((file) => file.localPath)
              .whereType<String>()
              .where((path) => path.isNotEmpty)
              .toList();
          if (paths.isEmpty) continue;

          final certificateId =
              certificate.id ??
              _resolveCertificateId(
                certificatesAfterPatch[egxuId],
                certificateIndex,
              );
          if (certificateId == null) {
            throw StateError('Sertifikat ID sini aniqlab bo\'lmadi');
          }
          await _api.uploadEgxuCertificateFiles(
            egxuId: egxuId,
            certificateId: certificateId,
            paths: paths,
          );
        }
      }

      // Iste'molchi fayllari (Loyiha texnik + Shartnoma)
      final consumerId = document.consumers?.id;
      final technicalPaths = state.pendingTechnical
          .map((f) => f.localPath)
          .whereType<String>()
          .toList();
      final contractPaths = state.pendingContracts
          .map((f) => f.localPath)
          .whereType<String>()
          .toList();
      if (consumerId != null &&
          (technicalPaths.isNotEmpty || contractPaths.isNotEmpty)) {
        await _api.uploadConsumerFiles(
          consumerId: consumerId,
          technicalPaths: technicalPaths,
          contractPaths: contractPaths,
        );
      }

      // Saqlangach yangilangan detail va fayllarni qayta yuklash
      final freshDocument = savedDocument.id == null
          ? savedDocument
          : await _api.getDocumentById(savedDocument.id!);
      final files = await _loadRemoteFiles(freshDocument);
      emit(
        state.copyWith(
          document: freshDocument,
          draftDocument: freshDocument,
          isDirty: false,
          certsByEgxu: files.certsByEgxu,
          technicalDocs: files.technical,
          contracts: files.contracts,
          pendingTechnical: const [],
          pendingContracts: const [],
          saveStatus: ConsumerDetailSaveStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ConsumerDetailSaveStatus.failure,
          saveError: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<_RemoteFiles> _loadRemoteFiles(
    WorkingWithConsumersDetailModel document,
  ) async {
    final certsByEgxu = <int, List<EgxuCertificate>>{};
    final egxuItems = document.egxuList ?? const <ConsumersEgxuItem>[];
    for (final item in egxuItems) {
      if (item.id != null) {
        certsByEgxu[item.id!] = [...?item.certificates];
      }
    }

    var technical = <ConsumerUploadFile>[];
    var contracts = <ConsumerUploadFile>[];
    final consumerId = document.consumers?.id;
    if (consumerId != null) {
      try {
        final files = await _api.getConsumerFiles(consumerId: consumerId);
        technical = files
            .where((f) => (f.fileType ?? '').toUpperCase() == 'TECHNICAL')
            .map(ConsumerUploadFile.fromConsumerFile)
            .toList();
        contracts = files
            .where((f) => (f.fileType ?? '').toUpperCase() == 'CONTRACT')
            .map(ConsumerUploadFile.fromConsumerFile)
            .toList();
      } catch (_) {
        // fayllar yuklanmasa bo'sh qoldiriladi
      }
    }

    return _RemoteFiles(
      certsByEgxu: certsByEgxu,
      technical: technical,
      contracts: contracts,
    );
  }

  bool _hasDocumentChangesAgainst(
    WorkingWithConsumersDetailModel? document,
    WorkingWithConsumersDetailModel? draft,
  ) {
    if (document == null || draft == null) return false;
    return jsonEncode(_normalizeJson(document.toJson())) !=
        jsonEncode(_normalizeJson(draft.toJson()));
  }

  Map<int, List<EgxuCertificate>> _copyCertificates(
    Map<int, List<EgxuCertificate>> source,
  ) => source.map((key, value) => MapEntry(key, [...value]));

  EgxuCertificate? _findCertificate(
    List<EgxuCertificate> certificates,
    EgxuCertificate target,
  ) {
    for (final certificate in certificates) {
      if (certificate.id != null && certificate.id == target.id) {
        return certificate;
      }
      if (certificate.localId != null &&
          certificate.localId == target.localId) {
        return certificate;
      }
    }
    return null;
  }

  List<EgxuCertificate> _replaceCertificate(
    List<EgxuCertificate> certificates,
    EgxuCertificate replacement,
  ) => certificates
      .map(
        (certificate) => _findCertificate([certificate], replacement) != null
            ? replacement
            : certificate,
      )
      .toList();

  WorkingWithConsumersDetailModel _documentWithCertificates(
    WorkingWithConsumersDetailModel document,
    Map<int, List<EgxuCertificate>> certificates, {
    required bool includeEmpty,
  }) {
    final items = document.egxuList
        ?.map(
          (item) => item.id == null
              ? item
              : item.copyWith(
                  certificates:
                      (certificates[item.id!] ?? item.certificates ?? const [])
                          .where(
                            (certificate) =>
                                includeEmpty ||
                                certificate.hasMetadata ||
                                certificate.files.isNotEmpty,
                          )
                          .toList(),
                ),
        )
        .toList();
    return document.copyWith(egxuList: items);
  }

  bool _certificatesNeedPatch(ConsumerDetailState current) {
    final original = <int, List<EgxuCertificate>>{
      for (final item
          in current.document?.egxuList ?? const <ConsumersEgxuItem>[])
        if (item.id != null) item.id!: [...?item.certificates],
    };
    for (final entry in current.certsByEgxu.entries) {
      final before = original[entry.key] ?? const <EgxuCertificate>[];
      for (final certificate in entry.value) {
        if (certificate.id == null &&
            (certificate.hasMetadata || certificate.files.isNotEmpty)) {
          return true;
        }
        if (certificate.id == null) {
          continue;
        }
        final previous = before.cast<EgxuCertificate?>().firstWhere(
          (candidate) => candidate?.id == certificate.id,
          orElse: () => null,
        );
        if (previous == null ||
            !_sameCertificateMetadata(previous, certificate)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _sameCertificateMetadata(EgxuCertificate a, EgxuCertificate b) =>
      a.certificateType == b.certificateType &&
      a.certificateNumber == b.certificateNumber &&
      a.issuedDate == b.issuedDate &&
      a.expiryDate == b.expiryDate &&
      a.warningLetter == b.warningLetter &&
      a.warningDate == b.warningDate &&
      a.warningReason == b.warningReason &&
      a.isActive == b.isActive;

  Map<int, List<EgxuCertificate>> _certificatesFromDocument(
    WorkingWithConsumersDetailModel document,
  ) => {
    for (final item in document.egxuList ?? const <ConsumersEgxuItem>[])
      if (item.id != null) item.id!: [...?item.certificates],
  };

  int? _resolveCertificateId(List<EgxuCertificate>? response, int index) {
    if (response == null) return null;
    if (index >= 0 && index < response.length) return response[index].id;
    return response.length == 1 ? response.first.id : null;
  }

  Object? _normalizeJson(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      for (final key in value.keys.map((e) => e.toString()).toList()..sort()) {
        sorted[key] = _normalizeJson(value[key]);
      }
      return sorted;
    }
    if (value is List) {
      return value.map(_normalizeJson).toList();
    }
    return value;
  }
}

class _RemoteFiles {
  final Map<int, List<EgxuCertificate>> certsByEgxu;
  final List<ConsumerUploadFile> technical;
  final List<ConsumerUploadFile> contracts;

  const _RemoteFiles({
    required this.certsByEgxu,
    required this.technical,
    required this.contracts,
  });
}
