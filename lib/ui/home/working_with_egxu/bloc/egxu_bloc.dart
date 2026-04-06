// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:m_gaz/core/api/egxu/exgu.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/bloc/egxu_event.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/bloc/egxu_state.dart';
// import '../../../../di.dart';
//
//
// class WorkingWIthEgxuBloc
//     extends Bloc<WorkingEgxuEvent, WorkingWithEgxuState> {
//   final _api = di.get<EGXUApi>();
//
//   WorkingWIthEgxuBloc() : super(const WorkingWithEgxuState()) {
//     on<WorkingWithEGXUFetched>(_onFetched);
//     on<WorkingWithEGXULoadMore>(_onLoadMore);
//     on<WorkingWithWEGXUDetailFetched>(_onDocumentFetched);
//   }
//
//   Future<void> _onFetched(
//       WorkingWithEGXUFetched event,
//       Emitter<WorkingWithEgxuState> emit,
//       ) async {
//     emit(state.copyWith(status: WorkingWithEgxuStatus.loading));
//     try {
//       final response = await _api.getDocuments(limit: 20);
//       emit(
//         state.copyWith(
//           status: WorkingWithEgxuStatus.success,
//           documents: response.results,
//           nextUrl: response.next,
//           hasReachedMax: response.next == null,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: WorkingWithEgxuStatus.fail,
//           errorMessage: e.toString().replaceAll('Exception: ', ''),
//         ),
//       );
//     }
//   }
//
//   Future<void> _onLoadMore(
//       WorkingWithEGXULoadMore event,
//       Emitter<WorkingWithEgxuState> emit,
//       ) async {
//     if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
//       return;
//     }
//
//     emit(state.copyWith(isLoadingMore: true));
//     try {
//       final response = await _api.getNextPage(state.nextUrl!);
//       emit(
//         state.copyWith(
//           status: WorkingWithEgxuStatus.success,
//           documents: [...state.documents, ...response.results],
//           nextUrl: response.next,
//           hasReachedMax: response.next == null,
//           isLoadingMore: false,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: WorkingWithEgxuStatus.fail,
//           errorMessage: e.toString().replaceAll('Exception: ', ''),
//           isLoadingMore: false,
//         ),
//       );
//     }
//   }
//
//   Future<void> _onDocumentFetched(
//       WorkingWithWEGXUDetailFetched event,
//       Emitter<WorkingWithEgxuState> emit,
//       ) async {
//     emit(state.copyWith(status: WorkingWithEgxuStatus.loading));
//     try {
//       final document = await _api.getDocumentById(event.documentId);
//       emit(
//         state.copyWith(
//           status: WorkingWithEgxuStatus.success,
//           selectedDocument: document,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: WorkingWithEgxuStatus.fail,
//           errorMessage: e.toString().replaceAll('Exception: ', ''),
//         ),
//       );
//     }
//   }
// }
