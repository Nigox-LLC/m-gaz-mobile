part of 'consumer_relations_bloc.dart';

abstract class ConsumerRelationsEvent extends Equatable {
  const ConsumerRelationsEvent();

  @override
  List<Object?> get props => [];
}

// Dastlabki yuklash
class ConsumerRelationsFetched extends ConsumerRelationsEvent {}

// Qo'shimcha ma'lumotlar yuklash (pagination)
class ConsumerRelationsLoadMore extends ConsumerRelationsEvent {}

class ConsumerRelationsDocumentFetched extends ConsumerRelationsEvent {
  final int documentId;

  const ConsumerRelationsDocumentFetched(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class CheckFactoryExistRequested extends ConsumerRelationsEvent {
  final String factory1;
  final String factory2;

  const CheckFactoryExistRequested({
    required this.factory1,
    required this.factory2,
  });
}

// Search query o'zgardi
class ConsumerRelationsSearchChanged extends ConsumerRelationsEvent {
  final String query;
  const ConsumerRelationsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// Region/district filter o'zgardi (kelajakdagi filter UI uchun)
class ConsumerRelationsFilterChanged extends ConsumerRelationsEvent {
  final int? regionId;
  final int? districtId;
  final bool clearRegion;
  final bool clearDistrict;

  const ConsumerRelationsFilterChanged({
    this.regionId,
    this.districtId,
    this.clearRegion = false,
    this.clearDistrict = false,
  });

  @override
  List<Object?> get props => [regionId, districtId, clearRegion, clearDistrict];
}
