// import 'package:equatable/equatable.dart';
// import 'package:m_gaz/core/models/egxu/egxu.dart';
//
// import '../../../../core/models/egxu/egxu_detail/working_with_egxu_detail.dart';
//
// enum WorkingWithEgxuStatus { initial, loading, success, fail }
//
// class WorkingWithEgxuState extends Equatable {
//   final WorkingWithEgxuStatus status;
//   final List<EGXUDocument> documents;
//   final String? nextUrl;
//   final bool hasReachedMax;
//   final bool isLoadingMore;
//   final String? errorMessage;
//
//   final WorkingWithEgxuDetail? selectedDocument;
//
//   const WorkingWithEgxuState({
//     this.status = WorkingWithEgxuStatus.initial,
//     this.documents = const [],
//     this.nextUrl,
//     this.hasReachedMax = false,
//     this.isLoadingMore = false,
//     this.errorMessage,
//     this.selectedDocument,
//   });
//
//   WorkingWithEgxuState copyWith({
//     WorkingWithEgxuStatus? status,
//     List<EGXUDocument>? documents,
//     String? nextUrl,
//     bool? hasReachedMax,
//     bool? isLoadingMore,
//     String? errorMessage,
//     WorkingWithEgxuDetail ? selectedDocument,
//   }) {
//     return WorkingWithEgxuState(
//       status: status ?? this.status,
//       documents: documents ?? this.documents,
//       nextUrl: nextUrl ?? this.nextUrl,
//       hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
//       errorMessage: errorMessage ?? this.errorMessage,
//       selectedDocument: selectedDocument ?? this.selectedDocument,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     status,
//     documents,
//     nextUrl,
//     hasReachedMax,
//     isLoadingMore,
//     errorMessage,
//     selectedDocument,
//   ];
// }
