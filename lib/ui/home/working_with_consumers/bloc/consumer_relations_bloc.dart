import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../di.dart';
import 'consumer_relations_state.dart';

part 'consumer_relations_event.dart';

class ConsumerRelationsBloc extends Bloc<ConsumerRelationsEvent, ConsumerRelationsState> {
  final _api = di.get<ConsumerRelationsApi>();

  ConsumerRelationsBloc() : super(const ConsumerRelationsState()) {
    on<ConsumerRelationsFetched>(_onFetched);
    on<ConsumerRelationsLoadMore>(_onLoadMore);
    on<CheckFactoryExistRequested>(_checkFactory);
    on<ConsumerRelationsDocumentFetched>(_onDocumentFetched);
    on<ConsumerRelationsSearchChanged>(
      _onSearchChanged,
      transformer: restartable(),
    );
    on<ConsumerRelationsFilterChanged>(
      _onFilterChanged,
      transformer: restartable(),
    );
  }

  // ============= Documents List =============
  Future<void> _onFetched(
      ConsumerRelationsFetched event,
      Emitter<ConsumerRelationsState> emit,
      ) async {
    emit(state.copyWith(
      documentsStatus: DocumentsStatus.loading,
      clearDocuments: true,
    ));

    try {
      final response = await _api.getDocuments(
        limit: 20,
        search: state.searchQuery,
        region: state.regionFilterId,
        district: state.districtFilterId,
      );

      emit(state.copyWith(
        documentsStatus: DocumentsStatus.loaded,
        documents: response.results,
        documentsPagination: PaginationInfo(
          count: response.count,
          next: response.next,
          hasMore: response.next != null,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        documentsStatus: DocumentsStatus.fail,
        generalStatus: ConsumerGeneralStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ============= Search Changed (debounced) =============
  Future<void> _onSearchChanged(
    ConsumerRelationsSearchChanged event,
    Emitter<ConsumerRelationsState> emit,
  ) async {
    // searchQuery'ni darhol state'ga yozish (UI sync uchun)
    emit(state.copyWith(searchQuery: event.query));

    // Debounce: 400ms ichida yangi event kelsa restartable() bekor qiladi
    await Future.delayed(const Duration(milliseconds: 400));
    if (emit.isDone) return;

    emit(state.copyWith(
      documentsStatus: DocumentsStatus.loading,
      clearDocuments: true,
    ));

    try {
      final response = await _api.getDocuments(
        limit: 20,
        search: event.query,
        region: state.regionFilterId,
        district: state.districtFilterId,
      );
      emit(state.copyWith(
        documentsStatus: DocumentsStatus.loaded,
        documents: response.results,
        documentsPagination: PaginationInfo(
          count: response.count,
          next: response.next,
          hasMore: response.next != null,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        documentsStatus: DocumentsStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ============= Filter Changed (region/district) =============
  Future<void> _onFilterChanged(
    ConsumerRelationsFilterChanged event,
    Emitter<ConsumerRelationsState> emit,
  ) async {
    emit(state.copyWith(
      regionFilterId: event.regionId,
      districtFilterId: event.districtId,
      clearRegionFilter: event.clearRegion,
      clearDistrictFilter: event.clearDistrict,
      documentsStatus: DocumentsStatus.loading,
      clearDocuments: true,
    ));

    try {
      final response = await _api.getDocuments(
        limit: 20,
        search: state.searchQuery,
        region: state.regionFilterId,
        district: state.districtFilterId,
      );
      emit(state.copyWith(
        documentsStatus: DocumentsStatus.loaded,
        documents: response.results,
        documentsPagination: PaginationInfo(
          count: response.count,
          next: response.next,
          hasMore: response.next != null,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        documentsStatus: DocumentsStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ============= Load More =============
  Future<void> _onLoadMore(
      ConsumerRelationsLoadMore event,
      Emitter<ConsumerRelationsState> emit,
      ) async {
    if (!state.hasMoreDocuments || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(
      documentsStatus: DocumentsStatus.loadingMore,
      isLoadingMore: true,
    ));

    try {
      final nextUrl = state.documentsPagination.next;
      if (nextUrl == null) return;

      final response = await _api.getNextPage(nextUrl);

      emit(state.copyWith(
        documentsStatus: DocumentsStatus.loaded,
        appendDocuments: true,
        documents: response.results,
        documentsPagination: PaginationInfo(
          next: response.next,
          hasMore: response.next != null,
        ),
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        documentsStatus: DocumentsStatus.fail,
        generalStatus: ConsumerGeneralStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isLoadingMore: false,
      ));
    }
  }

  // ============= Document Detail =============
  Future<void> _onDocumentFetched(
      ConsumerRelationsDocumentFetched event,
      Emitter<ConsumerRelationsState> emit,
      ) async {
    emit(state.copyWith(
      detailStatus: DocumentDetailStatus.loading,
      clearSelectedDocument: true,
    ));

    try {
      final document = await _api.getDocumentById(event.documentId);

      emit(state.copyWith(
        detailStatus: DocumentDetailStatus.loaded,
        selectedDocument: document,
      ));
    } catch (e) {
      emit(state.copyWith(
        detailStatus: DocumentDetailStatus.fail,
        generalStatus: ConsumerGeneralStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ============= Factory Check =============
  Future<void> _checkFactory(
      CheckFactoryExistRequested event,
      Emitter<ConsumerRelationsState> emit,
      ) async {
    emit(state.copyWith(factoryStatus: FactoryCheckStatus.checking));

    try {
      final res = await _api.checkFactoryExist(
        factory1: event.factory1,
        factory2: event.factory2,
      );

      if (res.exists) {
        emit(state.copyWith(
          factoryStatus: FactoryCheckStatus.exists,
          factoryExists: true,
        ));
      } else {
        emit(state.copyWith(
          factoryStatus: FactoryCheckStatus.notExists,
          factoryExists: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        factoryStatus: FactoryCheckStatus.error,
        generalStatus: ConsumerGeneralStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }
}