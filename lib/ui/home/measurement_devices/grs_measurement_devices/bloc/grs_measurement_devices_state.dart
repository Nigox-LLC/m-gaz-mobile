
import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/grs/grs_measurement_model.dart';
import '../../../../../core/models/grs/grs_detail_model/grs_detail_model.dart';


enum GrsMeasurementDevicesStatus { initial, loading, success, fail }

class GrsMeasurementDevicesState extends Equatable {
  final GrsMeasurementDevicesStatus status;
  final List<GrsMeasurementModel> items;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  final GrsMeasurementModel? selectedDocument;
  final GrsDetailModel? grsDetail;

  const GrsMeasurementDevicesState({
    this.status = GrsMeasurementDevicesStatus.initial,
    this.items = const [],
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedDocument,
    this.grsDetail
  });

  GrsMeasurementDevicesState copyWith({
    GrsMeasurementDevicesStatus? status,
    List<GrsMeasurementModel>? items,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    GrsMeasurementModel? selectedDocument,
    GrsDetailModel? grsDetail,
  }) {
    return GrsMeasurementDevicesState(
      status: status ?? this.status,
      items: items ?? this.items,
      nextUrl: nextUrl ?? this.nextUrl,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      grsDetail: grsDetail ?? this.grsDetail,
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
        grsDetail
      ];
}
