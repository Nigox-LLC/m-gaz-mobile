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
