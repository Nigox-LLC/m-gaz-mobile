part of 'eghu_indicator_list_bloc.dart';

enum EghuIndicatorListStatus { initial, loading, success, failure, loadingMore }

class EghuIndicatorListState extends Equatable {
  const EghuIndicatorListState({
    this.status = EghuIndicatorListStatus.initial,
    this.documents = const [],
    this.nextUrl,
    this.errorMessage = '',
    this.searchQuery = '',
    this.filter = const EghuIndicatorListFilter(),
  });

  final EghuIndicatorListStatus status;
  final List<EghuIndicatorDocument> documents;
  final String? nextUrl;
  final String errorMessage;
  final String searchQuery;
  final EghuIndicatorListFilter filter;

  bool get hasNextPage => nextUrl?.isNotEmpty == true;
  bool get hasActiveFilters => filter.hasActiveFilters;
  bool get isInitialLoading =>
      status == EghuIndicatorListStatus.initial ||
      (status == EghuIndicatorListStatus.loading && documents.isEmpty);
  bool get isLoadingMore => status == EghuIndicatorListStatus.loadingMore;

  EghuIndicatorListState copyWith({
    EghuIndicatorListStatus? status,
    List<EghuIndicatorDocument>? documents,
    String? nextUrl,
    String? errorMessage,
    String? searchQuery,
    EghuIndicatorListFilter? filter,
    bool clearNextUrl = false,
    bool clearDocuments = false,
  }) {
    return EghuIndicatorListState(
      status: status ?? this.status,
      documents: clearDocuments ? const [] : (documents ?? this.documents),
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    documents,
    nextUrl,
    errorMessage,
    searchQuery,
    filter,
  ];
}

class EghuIndicatorListFilter extends Equatable {
  const EghuIndicatorListFilter({
    this.startDate,
    this.endDate,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;

  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      regionId != null ||
      districtId != null;

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    regionId,
    regionName,
    districtId,
    districtName,
  ];
}
