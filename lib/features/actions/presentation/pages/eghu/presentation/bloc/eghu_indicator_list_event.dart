part of 'eghu_indicator_list_bloc.dart';

sealed class EghuIndicatorListEvent extends Equatable {
  const EghuIndicatorListEvent();

  @override
  List<Object?> get props => [];
}

class EghuIndicatorListStarted extends EghuIndicatorListEvent {
  const EghuIndicatorListStarted();
}

class EghuIndicatorListRefreshed extends EghuIndicatorListEvent {
  const EghuIndicatorListRefreshed();
}

class EghuIndicatorListLoadMoreRequested extends EghuIndicatorListEvent {
  const EghuIndicatorListLoadMoreRequested();
}

class EghuIndicatorSearchChanged extends EghuIndicatorListEvent {
  const EghuIndicatorSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class EghuIndicatorFilterChanged extends EghuIndicatorListEvent {
  const EghuIndicatorFilterChanged(this.filter);

  final EghuIndicatorListFilter filter;

  @override
  List<Object?> get props => [filter];
}
