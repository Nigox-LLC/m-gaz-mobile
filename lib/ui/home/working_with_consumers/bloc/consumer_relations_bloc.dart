import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../di.dart';
import 'consumer_relations_state.dart';

part 'consumer_relations_event.dart';

class ConsumerRelationsBloc
    extends Bloc<ConsumerRelationsEvent, ConsumerRelationsState> {
  final _api = di.get<ConsumerRelationsApi>();

  ConsumerRelationsBloc() : super(const ConsumerRelationsState()) {
    on<ConsumerRelationsFetched>(_onFetched);
    on<ConsumerRelationsLoadMore>(_onLoadMore);
    on<CheckFactoryExistRequested>(_checkFactory);
    on<ConsumerRelationsDocumentFetched>(_onDocumentFetched);
  }

  Future<void> _onFetched(
    ConsumerRelationsFetched event,
    Emitter<ConsumerRelationsState> emit,
  ) async {
    emit(state.copyWith(status: ConsumerRelationsStatus.loading));
    try {
      final response = await _api.getDocuments(limit: 20);
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.success,
          documents: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    ConsumerRelationsLoadMore event,
    Emitter<ConsumerRelationsState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await _api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.success,
          documents: [...state.documents, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onDocumentFetched(
    ConsumerRelationsDocumentFetched event,
    Emitter<ConsumerRelationsState> emit,
  ) async {
    emit(state.copyWith(status: ConsumerRelationsStatus.loading));
    try {
      final document = await _api.getDocumentById(event.documentId);
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.success,
          selectedDocument: document,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _checkFactory(
    CheckFactoryExistRequested event,
    Emitter<ConsumerRelationsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ConsumerRelationsStatus.loading));

      final res = await _api.checkFactoryExist(
        factory1: event.factory1,
        factory2: event.factory2,
      );

      if (res.exists) {
        emit(state.copyWith(status: ConsumerRelationsStatus.exist));
      } else {
        emit(state.copyWith(status: ConsumerRelationsStatus.success));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsumerRelationsStatus.fail,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
