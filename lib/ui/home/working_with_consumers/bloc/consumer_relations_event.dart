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
