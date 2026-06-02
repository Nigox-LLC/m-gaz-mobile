part of 'consumer_detail_bloc.dart';

abstract class ConsumerDetailEvent extends Equatable {
  const ConsumerDetailEvent();

  @override
  List<Object?> get props => [];
}

class ConsumerDetailFetched extends ConsumerDetailEvent {
  final int documentId;

  const ConsumerDetailFetched(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class ConsumerDetailCompanyToggled extends ConsumerDetailEvent {
  const ConsumerDetailCompanyToggled();
}

class ConsumerDetailFileAdded extends ConsumerDetailEvent {
  final ConsumerFileSlot slot;
  final int? egxuId;
  final ConsumerUploadFile file;

  const ConsumerDetailFileAdded({
    required this.slot,
    required this.file,
    this.egxuId,
  });

  @override
  List<Object?> get props => [slot, egxuId, file];
}

class ConsumerDetailFileRemoved extends ConsumerDetailEvent {
  final ConsumerFileSlot slot;
  final int? egxuId;
  final ConsumerUploadFile file;

  const ConsumerDetailFileRemoved({
    required this.slot,
    required this.file,
    this.egxuId,
  });

  @override
  List<Object?> get props => [slot, egxuId, file];
}

class ConsumerDetailSaved extends ConsumerDetailEvent {
  const ConsumerDetailSaved();
}
