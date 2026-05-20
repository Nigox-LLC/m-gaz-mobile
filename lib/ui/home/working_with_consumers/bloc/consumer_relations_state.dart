import 'package:equatable/equatable.dart';

import '../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';

// Alohida statuslar har bir ma'lumot turi uchun
enum ConsumerGeneralStatus { initial, loading, success, fail }

enum FactoryCheckStatus { initial, checking, exists, notExists, error }

enum DocumentsStatus { initial, loading, loaded, loadingMore, fail }

enum DocumentDetailStatus { initial, loading, loaded, fail }

class PaginationInfo extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final int currentPage;
  final bool hasMore;

  const PaginationInfo({
    this.count = 0,
    this.next,
    this.previous,
    this.currentPage = 1,
    this.hasMore = false,
  });

  PaginationInfo copyWith({
    int? count,
    String? next,
    String? previous,
    int? currentPage,
    bool? hasMore,
  }) {
    return PaginationInfo(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  int? get nextPage {
    if (!hasMore || next == null || next!.isEmpty) return null;
    try {
      final uri = Uri.parse(next!);
      final pageParam = uri.queryParameters['page'];
      if (pageParam != null) {
        return int.tryParse(pageParam);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [count, next, previous, currentPage, hasMore];
}

class ConsumerRelationsState extends Equatable {
  // Umumiy status
  final ConsumerGeneralStatus generalStatus;
  final String? errorMessage;

  // Factory check alohida status
  final FactoryCheckStatus factoryStatus;
  final bool? factoryExists;

  // Hujjatlar ro'yxati alohida status
  final DocumentsStatus documentsStatus;
  final List<WorkingWithConsumersList> documents;
  final PaginationInfo documentsPagination;
  final bool isLoadingMore;

  // Hujjat detali alohida status
  final DocumentDetailStatus detailStatus;
  final WorkingWithConsumersDetailModel? selectedDocument;

  // Eski status (backward compatibility uchun)
  final ConsumerGeneralStatus? legacyStatus;

  // Search & filter holati
  final String searchQuery;
  final int? regionFilterId;
  final int? districtFilterId;

  const ConsumerRelationsState({
    this.generalStatus = ConsumerGeneralStatus.initial,
    this.errorMessage,
    this.factoryStatus = FactoryCheckStatus.initial,
    this.factoryExists,
    this.documentsStatus = DocumentsStatus.initial,
    this.documents = const [],
    this.documentsPagination = const PaginationInfo(),
    this.isLoadingMore = false,
    this.detailStatus = DocumentDetailStatus.initial,
    this.selectedDocument,
    this.legacyStatus,
    this.searchQuery = '',
    this.regionFilterId,
    this.districtFilterId,
  });

  // Helper getterlar
  bool get isLoading => generalStatus == ConsumerGeneralStatus.loading;
  bool get isSuccess => generalStatus == ConsumerGeneralStatus.success;
  bool get isFail => generalStatus == ConsumerGeneralStatus.fail;

  bool get isFactoryChecking => factoryStatus == FactoryCheckStatus.checking;
  bool get isFactoryExists => factoryStatus == FactoryCheckStatus.exists;
  bool get isFactoryNotExists => factoryStatus == FactoryCheckStatus.notExists;

  bool get isDocumentsLoading => documentsStatus == DocumentsStatus.loading;
  bool get isDocumentsLoaded => documentsStatus == DocumentsStatus.loaded;
  bool get isDocumentsLoadingMore => documentsStatus == DocumentsStatus.loadingMore;
  bool get hasMoreDocuments => documentsPagination.hasMore;

  bool get isDetailLoading => detailStatus == DocumentDetailStatus.loading;
  bool get isDetailLoaded => detailStatus == DocumentDetailStatus.loaded;

  // Backward compatibility
  bool get hasReachedMax => !documentsPagination.hasMore;

  ConsumerRelationsState copyWith({
    ConsumerGeneralStatus? generalStatus,
    String? errorMessage,
    FactoryCheckStatus? factoryStatus,
    bool? factoryExists,
    DocumentsStatus? documentsStatus,
    List<WorkingWithConsumersList>? documents,
    PaginationInfo? documentsPagination,
    bool? isLoadingMore,
    DocumentDetailStatus? detailStatus,
    WorkingWithConsumersDetailModel? selectedDocument,
    ConsumerGeneralStatus? legacyStatus,
    String? searchQuery,
    int? regionFilterId,
    int? districtFilterId,
    bool clearDocuments = false,
    bool clearSelectedDocument = false,
    bool appendDocuments = false,
    bool clearRegionFilter = false,
    bool clearDistrictFilter = false,
  }) {
    return ConsumerRelationsState(
      generalStatus: generalStatus ?? this.generalStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      factoryStatus: factoryStatus ?? this.factoryStatus,
      factoryExists: factoryExists ?? this.factoryExists,
      documentsStatus: documentsStatus ?? this.documentsStatus,
      documents: clearDocuments
          ? const []
          : appendDocuments
          ? [...this.documents, ...(documents ?? [])]
          : (documents ?? this.documents),
      documentsPagination: documentsPagination ?? this.documentsPagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedDocument: clearSelectedDocument
          ? null
          : (selectedDocument ?? this.selectedDocument),
      legacyStatus: legacyStatus ?? this.legacyStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      regionFilterId: clearRegionFilter
          ? null
          : (regionFilterId ?? this.regionFilterId),
      districtFilterId: clearDistrictFilter
          ? null
          : (districtFilterId ?? this.districtFilterId),
    );
  }

  @override
  List<Object?> get props => [
    generalStatus,
    errorMessage,
    factoryStatus,
    factoryExists,
    documentsStatus,
    documents,
    documentsPagination,
    isLoadingMore,
    detailStatus,
    selectedDocument,
    legacyStatus,
    searchQuery,
    regionFilterId,
    districtFilterId,
  ];
}