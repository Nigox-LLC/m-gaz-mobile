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

class ConsumerDetailEgxuToggled extends ConsumerDetailEvent {
  final int egxuId;

  const ConsumerDetailEgxuToggled(this.egxuId);

  @override
  List<Object?> get props => [egxuId];
}

class ConsumerDetailCompanyChanged extends ConsumerDetailEvent {
  final ConsumersCompanyInfo companyInfo;

  const ConsumerDetailCompanyChanged(this.companyInfo);

  @override
  List<Object?> get props => [companyInfo];
}

class ConsumerDetailEgxuRelationChanged extends ConsumerDetailEvent {
  final int egxuId;
  final ConsumerRelationEgxu relation;

  const ConsumerDetailEgxuRelationChanged({
    required this.egxuId,
    required this.relation,
  });

  @override
  List<Object?> get props => [egxuId, relation];
}

class ConsumerDetailEgxuItemChanged extends ConsumerDetailEvent {
  final ConsumersEgxuItem item;

  const ConsumerDetailEgxuItemChanged(this.item);

  @override
  List<Object?> get props => [item];
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

class ConsumerDetailCertificateChanged extends ConsumerDetailEvent {
  final int egxuId;
  final ConsumerUploadFile certificate;

  const ConsumerDetailCertificateChanged({
    required this.egxuId,
    required this.certificate,
  });

  @override
  List<Object?> get props => [egxuId, certificate];
}

class ConsumerDetailSaved extends ConsumerDetailEvent {
  const ConsumerDetailSaved();
}
