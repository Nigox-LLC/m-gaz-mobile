part of 'eghu_action_list_bloc.dart';

enum EghuActionListStatus { initial, loading, success, failure, loadingMore }

class EghuActionListState extends Equatable {
  const EghuActionListState({
    this.status = EghuActionListStatus.initial,
    this.documents = const [],
    this.nextUrl,
    this.errorMessage = '',
    this.searchQuery = '',
    this.filter = const EghuActionListFilter(),
  });

  final EghuActionListStatus status;
  final List<EghuWorkingDocument> documents;
  final String? nextUrl;
  final String errorMessage;
  final String searchQuery;
  final EghuActionListFilter filter;

  bool get hasNextPage => nextUrl?.isNotEmpty == true;
  bool get isInitialLoading =>
      status == EghuActionListStatus.initial ||
      (status == EghuActionListStatus.loading && documents.isEmpty);
  bool get isLoadingMore => status == EghuActionListStatus.loadingMore;
  bool get hasActiveFilters => filter.hasActiveFilters;

  EghuActionListState copyWith({
    EghuActionListStatus? status,
    List<EghuWorkingDocument>? documents,
    String? nextUrl,
    String? errorMessage,
    String? searchQuery,
    EghuActionListFilter? filter,
    bool clearNextUrl = false,
    bool clearDocuments = false,
  }) {
    return EghuActionListState(
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

enum EghuActionReasonFilter {
  repair('repair'),
  eghuImprovement('eghu_improvement'),
  periodicComparison('periodic_comparison'),
  other('other');

  const EghuActionReasonFilter(this.apiValue);

  final String apiValue;
}

class EghuActionListFilter extends Equatable {
  const EghuActionListFilter({
    this.dateFrom,
    this.dateTo,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
    this.reason,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;
  final EghuActionReasonFilter? reason;

  bool get hasActiveFilters =>
      dateFrom != null ||
      dateTo != null ||
      regionId != null ||
      districtId != null ||
      reason != null;

  EghuActionListFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? regionId,
    String? regionName,
    int? districtId,
    String? districtName,
    EghuActionReasonFilter? reason,
    bool clearDates = false,
    bool clearRegion = false,
    bool clearDistrict = false,
    bool clearReason = false,
  }) {
    return EghuActionListFilter(
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      regionId: clearRegion ? null : (regionId ?? this.regionId),
      regionName: clearRegion ? null : (regionName ?? this.regionName),
      districtId: clearDistrict ? null : (districtId ?? this.districtId),
      districtName: clearDistrict ? null : (districtName ?? this.districtName),
      reason: clearReason ? null : (reason ?? this.reason),
    );
  }

  @override
  List<Object?> get props => [
    dateFrom,
    dateTo,
    regionId,
    regionName,
    districtId,
    districtName,
    reason,
  ];
}
