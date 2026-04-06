import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/working-with-stamps/working_with_stamps.dart';
import '../../../../core/models/working-with-stamps/detail/workign_with_stamp_detail.dart';

enum WorkingWithStampStatus { initial, loading, success, fail }

class WorkingWithStampState extends Equatable {
  final WorkingWithStampStatus status;
  final List<WorkingWithStampsModel> documents;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  final WorkingWithStampsDetailModel? selectedDocument;

  const WorkingWithStampState({
    this.status = WorkingWithStampStatus.initial,
    this.documents = const [],
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedDocument,
  });

  WorkingWithStampState copyWith({
    WorkingWithStampStatus? status,
    List<WorkingWithStampsModel>? documents,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    WorkingWithStampsDetailModel? selectedDocument,
  }) {
    return WorkingWithStampState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      nextUrl: nextUrl ?? this.nextUrl,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDocument: selectedDocument ?? this.selectedDocument,
    );
  }

  @override
  List<Object?> get props => [
    status,
    documents,
    nextUrl,
    hasReachedMax,
    isLoadingMore,
    errorMessage,
    selectedDocument,
  ];
}
