import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/ui/home/working-with-stamps/bloc/working_with_stamps_event.dart';
import 'package:m_gaz/ui/home/working-with-stamps/bloc/working_with_stamps_state.dart';
import '../../../../core/api/working-with-stamps/working_with_stamps_api.dart';
import '../../../../di.dart';

class WorkingWithStampBloc
    extends Bloc<WorkingWithStampEvent, WorkingWithStampState> {
  final _api = di.get<WorkingWithStampsApi>();

  WorkingWithStampBloc() : super(const WorkingWithStampState()) {
    on<WorkingWithStampFetched>(_onFetched);
    on<WorkingWithStampLoadMore>(_onLoadMore);
    on<WorkingWithStampDocumentFetched>(_onDocumentFetched);
  }

  Future<void> _onFetched(
    WorkingWithStampFetched event,
    Emitter<WorkingWithStampState> emit,
  ) async {
    emit(state.copyWith(status: WorkingWithStampStatus.loading));
    try {
      final response = await _api.getDocuments(limit: 20);
      emit(
        state.copyWith(
          status: WorkingWithStampStatus.success,
          documents: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkingWithStampStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    WorkingWithStampLoadMore event,
    Emitter<WorkingWithStampState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await _api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: WorkingWithStampStatus.success,
          documents: [...state.documents, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkingWithStampStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onDocumentFetched(
    WorkingWithStampDocumentFetched event,
    Emitter<WorkingWithStampState> emit,
  ) async {
    emit(state.copyWith(status: WorkingWithStampStatus.loading));
    try {
      final document = await _api.getDocumentById(event.documentId);
      emit(
        state.copyWith(
          status: WorkingWithStampStatus.success,
          selectedDocument: document,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkingWithStampStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
