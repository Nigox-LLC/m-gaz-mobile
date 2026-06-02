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
    on<ConsumerDetailFileAdded>(_onFileAdded);
    on<ConsumerDetailFileRemoved>(_onFileRemoved);
    on<ConsumerDetailSaved>(_onSaved);
  }

  Future<void> _onFetched(
    ConsumerDetailFetched event,
    Emitter<ConsumerDetailState> emit,
  ) async {
    emit(
      const ConsumerDetailState(status: ConsumerDetailStatus.loading),
    );

    try {
      final document = await _api.getDocumentById(event.documentId);
      final files = await _loadRemoteFiles(document);

      emit(
        ConsumerDetailState(
          status: ConsumerDetailStatus.loaded,
          document: document,
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
        emit(state.copyWith(pendingCertsByEgxu: map, saveStatus: ConsumerDetailSaveStatus.idle));
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
    final document = state.document;
    if (document == null || !state.hasPending) return;

    emit(state.copyWith(saveStatus: ConsumerDetailSaveStatus.saving));

    try {
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

      // Saqlangach yangilangan ro'yxatni qayta yuklash
      final files = await _loadRemoteFiles(document);
      emit(
        state.copyWith(
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
          certsByEgxu[e.id!] =
              certs.map(ConsumerUploadFile.fromCertificate).toList();
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
