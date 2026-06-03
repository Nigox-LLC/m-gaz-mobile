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
        final egxuId = event.egxuId;
        if (egxuId == null) return;
        final map = Map<int, List<ConsumerUploadFile>>.from(
          state.pendingCertsByEgxu,
        );
        map[egxuId] = [...?map[egxuId], event.file];
        emit(
          state.copyWith(
            pendingCertsByEgxu: map,
            saveStatus: ConsumerDetailSaveStatus.idle,
          ),
        );
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
        final egxuId = event.egxuId;
        if (egxuId == null) return;
        final map = Map<int, List<ConsumerUploadFile>>.from(
          state.pendingCertsByEgxu,
        );
        map[egxuId] = (map[egxuId] ?? [])
            .where((f) => f != event.file)
            .toList();
        emit(state.copyWith(pendingCertsByEgxu: map));
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

  Future<void> _onSaved(
    ConsumerDetailSaved event,
    Emitter<ConsumerDetailState> emit,
  ) async {
    final document = state.draftDocument ?? state.document;
    final hasDocumentChanges = _hasDocumentChanges(state);
    if (document == null || (!state.hasPending && !hasDocumentChanges)) return;

    emit(state.copyWith(saveStatus: ConsumerDetailSaveStatus.saving));

    try {
      var savedDocument = document;
      final documentId = document.id;
      if (hasDocumentChanges && documentId != null) {
        savedDocument = await _api.patchDocument(
          id: documentId,
          document: document,
        );
      }

      // EGHU sertifikatlari
      for (final entry in state.pendingCertsByEgxu.entries) {
        final paths = entry.value
            .map((f) => f.localPath)
            .whereType<String>()
            .toList();
        if (paths.isNotEmpty) {
          await _api.uploadEgxuCertificates(egxuId: entry.key, paths: paths);
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
          pendingCertsByEgxu: const {},
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
    final certsByEgxu = <int, List<ConsumerUploadFile>>{};
    final egxuItems = document.egxuList ?? const <ConsumersEgxuItem>[];

    await Future.wait(
      egxuItems.where((e) => e.id != null).map((e) async {
        try {
          final certs = await _api.getEgxuCertificates(egxuId: e.id!);
          certsByEgxu[e.id!] = certs
              .map(ConsumerUploadFile.fromCertificate)
              .toList();
        } catch (_) {
          certsByEgxu[e.id!] = const [];
        }
      }),
    );

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

  bool _hasDocumentChanges(ConsumerDetailState state) {
    final document = state.document;
    final draft = state.draftDocument;
    if (document == null || draft == null) return false;
    return jsonEncode(_normalizeJson(document.toJson())) !=
        jsonEncode(_normalizeJson(draft.toJson()));
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
  final Map<int, List<ConsumerUploadFile>> certsByEgxu;
  final List<ConsumerUploadFile> technical;
  final List<ConsumerUploadFile> contracts;

  const _RemoteFiles({
    required this.certsByEgxu,
    required this.technical,
    required this.contracts,
  });
}
