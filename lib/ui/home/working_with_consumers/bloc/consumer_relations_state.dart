import 'package:equatable/equatable.dart';

import '../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';

enum ConsumerRelationsStatus {
  initial,
  loading,
  success,
  fail,
  exist,
  notExist,
}

class ConsumerRelationsState extends Equatable {
  final ConsumerRelationsStatus status;
  final bool? factoryExists;
  final List<WorkingWithConsumersList> documents;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  final WorkingWithConsumersDetailModel? selectedDocument;

  const ConsumerRelationsState({
    this.status = ConsumerRelationsStatus.initial,
    this.factoryExists,
    this.documents = const [],
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedDocument,
  });

  ConsumerRelationsState copyWith({
    ConsumerRelationsStatus? status,
    bool? factoryExists,
    List<WorkingWithConsumersList>? documents,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    WorkingWithConsumersDetailModel? selectedDocument,
  }) {
    return ConsumerRelationsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      factoryExists: factoryExists ?? this.factoryExists,
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
    factoryExists,
    documents,
    nextUrl,
    hasReachedMax,
    isLoadingMore,
    errorMessage,
    selectedDocument,
  ];
}
