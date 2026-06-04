enum Status {
  initial,
  success,
  error,
  loading,
  empty,
  offline;

  bool get isInitial => this == Status.initial;
  bool get isSuccess => this == Status.success;
  bool get isError => this == Status.error;
  bool get isLoading => this == Status.loading;
  bool get isEmpty => this == Status.empty;
  bool get isOffline => this == Status.offline;
}
