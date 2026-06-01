part of 'eghu_action_list_bloc.dart';

sealed class EghuActionListEvent extends Equatable {
  const EghuActionListEvent();

  @override
  List<Object?> get props => [];
}

class EghuActionListStarted extends EghuActionListEvent {
  const EghuActionListStarted();
}

class EghuActionListRefreshed extends EghuActionListEvent {
  const EghuActionListRefreshed();
}

class EghuActionListLoadMoreRequested extends EghuActionListEvent {
  const EghuActionListLoadMoreRequested();
}

class EghuActionListSearchChanged extends EghuActionListEvent {
  const EghuActionListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class EghuActionListFilterChanged extends EghuActionListEvent {
  const EghuActionListFilterChanged(this.filter);

  final EghuActionListFilter filter;

  @override
  List<Object?> get props => [filter];
}
