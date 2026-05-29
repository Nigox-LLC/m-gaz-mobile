part of 'eghu_action_list_bloc.dart';

enum EghuActionListStatus { initial, loading, success, failure, loadingMore }

class EghuActionListState extends Equatable {
  const EghuActionListState({
    this.status = EghuActionListStatus.initial,
    this.documents = const [],
    this.nextUrl,
    this.errorMessage = '',
  });

  final EghuActionListStatus status;
  final List<EghuWorkingDocument> documents;
  final String? nextUrl;
  final String errorMessage;

  bool get hasNextPage => nextUrl?.isNotEmpty == true;
  bool get isInitialLoading =>
      status == EghuActionListStatus.initial ||
      (status == EghuActionListStatus.loading && documents.isEmpty);
  bool get isLoadingMore => status == EghuActionListStatus.loadingMore;

  EghuActionListState copyWith({
    EghuActionListStatus? status,
    List<EghuWorkingDocument>? documents,
    String? nextUrl,
    String? errorMessage,
    bool clearNextUrl = false,
  }) {
    return EghuActionListState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, documents, nextUrl, errorMessage];
}
