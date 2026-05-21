import 'package:equatable/equatable.dart';
import '../../../../../../../core/models/global/global_model.dart';
import '../../../../../../../features/auth/domain/entities/user.dart';
import '../widget/egxu_item.dart';

abstract class ConsumerCreateEvent extends Equatable {
  const ConsumerCreateEvent();

  @override
  List<Object?> get props => [];
}

class ConsumerCreateStarted extends ConsumerCreateEvent {
  final User currentUser;

  const ConsumerCreateStarted(this.currentUser);
}

class ConsumerConsumerSelected extends ConsumerCreateEvent {
  final GlobalModel consumer;

  const ConsumerConsumerSelected(this.consumer);
}

class ConsumerCreateNextStep extends ConsumerCreateEvent {}

class ConsumerCreatePreviousStep extends ConsumerCreateEvent {}

class ConsumerItemAdded extends ConsumerCreateEvent {
  final EgxuItem item;

  const ConsumerItemAdded(this.item);
}

class ConsumerTamgaAdded extends ConsumerCreateEvent {
  final StampModel item;

  const ConsumerTamgaAdded(this.item);
}

class ConsumerGazAdded extends ConsumerCreateEvent {
  final GazUsageResult item;

  const ConsumerGazAdded(this.item);
}

class ConsumerStep2DataSubmitted extends ConsumerCreateEvent {
  final Map<String, dynamic> data;

  const ConsumerStep2DataSubmitted(this.data);
}

class ConsumerStep3DataSubmitted extends ConsumerCreateEvent {
  final Map<String, dynamic> data;

  const ConsumerStep3DataSubmitted(this.data);
}

class ConsumerDataSubmitted extends ConsumerCreateEvent {
  const ConsumerDataSubmitted();
}
