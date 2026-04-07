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
      final response = await _api.getDocuments(limit: 20);

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