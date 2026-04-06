import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_detail.dart';
import '../../../../../core/models/technological-measuring/technological_measuring.dart';


enum TechMeasureStatus { initial, loading, success, fail }

class TechMeasureState extends Equatable {
  final TechMeasureStatus status;
  final List<TechnologicalMeasuringDocument> items;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  final TechnologicalMeasuringDocument? selectedDocument;
  final TeachMeasureDetail? teachMeasureDetail;

  const TechMeasureState({
    this.status = TechMeasureStatus.initial,
    this.items = const [],
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedDocument,
    this.teachMeasureDetail
  });

  TechMeasureState copyWith({
    TechMeasureStatus? status,
    List<TechnologicalMeasuringDocument>? items,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    TechnologicalMeasuringDocument? selectedDocument,
    TeachMeasureDetail? teachMeasureDetail,
  }) {
    return TechMeasureState(
      status: status ?? this.status,
      items: items ?? this.items,
      nextUrl: nextUrl ?? this.nextUrl,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      teachMeasureDetail: teachMeasureDetail ?? this.teachMeasureDetail,
      selectedDocument: selectedDocument ?? this.selectedDocument,
    );
  }

  @override
  List<Object?> get props =>
      [
        status,
        items,
        nextUrl,
        hasReachedMax,
        isLoadingMore,
        errorMessage,
        selectedDocument,
        teachMeasureDetail
      ];
}
