import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/extension/message_extension.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../../../di.dart';
import '../../../../../../../features/auth/presentation/bloc/login_bloc.dart';
import '../../../../../data/datasources/eghu_indicator_api.dart';
import '../bloc/eghu_indicator_detail_bloc/eghu_indicator_detail_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import 'eghu_indicator_create_page.dart';

class EghuIndicatorDetailPage extends StatefulWidget {
  const EghuIndicatorDetailPage({
    super.key,
    required this.id,
    this.api,
    this.consumerApi,
    this.consumerSource,
    this.bloc,
  });

  final int id;
  final EghuIndicatorDetailApi? api;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuIndicatorDetailBloc? bloc;

  @override
  State<EghuIndicatorDetailPage> createState() =>
      _EghuIndicatorDetailPageState();
}

class _EghuIndicatorDetailPageState extends State<EghuIndicatorDetailPage> {
  final _valueController = TextEditingController();
  final _imagePicker = ImagePicker();
  EghuIndicatorDetailBloc? _bloc;
  EghuActionConsumerSource? _consumerSource;
  bool _profileLoadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _consumerSource ??=
        widget.consumerSource ??
        ConsumerRelationsEghuSource(
          widget.consumerApi ?? di.get<ConsumerRelationsApi>(),
        );

    final profile = _readLoginState(context);
    _bloc ??=
        widget.bloc ??
        (EghuIndicatorDetailBloc(
          api: widget.api ?? di.get<EghuIndicatorApi>(),
          id: widget.id,
          employeeName: profile?.user?.username,
        )..add(const EghuIndicatorDetailStarted()));

    if (profile?.user == null) {
      _requestProfileLoad(context);
    } else {
      _syncProfile(profile!);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider.value(
      value: _bloc!,
      child: BlocConsumer<EghuIndicatorDetailBloc, EghuIndicatorDetailState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onSubmitStateChanged,
        builder: (context, state) {
          if (state.status == EghuIndicatorDetailStatus.loading ||
              state.status == EghuIndicatorDetailStatus.initial) {
            return const Scaffold(
              backgroundColor: EghuActionCreateColors.white,
              body: SafeArea(child: Center(child: CircularProgressIndicator())),
            );
          }

          if (state.status == EghuIndicatorDetailStatus.failure) {
            return _DetailFailure(
              message: state.errorMessage,
              onRetry: () => context.read<EghuIndicatorDetailBloc>().add(
                const EghuIndicatorDetailStarted(),
              ),
            );
          }

          syncEghuIndicatorValueController(_valueController, state.value);
          return EghuIndicatorFormView(
            title: Words.actionEghuIndicatorUpload.tr(),
            valueController: _valueController,
            selectedConsumerText: state.selectedConsumer == null
                ? Words.selectConsumer.tr()
                : state.selectedConsumer!.consumers,
            selectedConsumerPlaceholder: state.selectedConsumer == null,
            selectedEghuText: state.selectedEghu == null
                ? Words.selectEghu.tr()
                : eghuTitle(state.selectedEghu!),
            selectedEghuPlaceholder: state.selectedEghu == null,
            basicFiles: state.basicFile == null ? const [] : [state.basicFile!],
            printFiles: state.printFile == null ? const [] : [state.printFile!],
            employeeName: state.employeeName,
            canSubmit: state.canSubmit,
            loading: state.status == EghuIndicatorDetailStatus.submitting,
            submitLabel: Words.save.tr(),
            onValueChanged: (value) => context
                .read<EghuIndicatorDetailBloc>()
                .add(EghuIndicatorDetailValueChanged(value)),
            onSelectConsumer: () => _selectConsumer(context, state),
            onSelectEghu: () => _selectEghu(context, state),
            onPickBasic: () =>
                _pickAttachment(context, EghuIndicatorUploadTarget.basic),
            onRemoveBasicAt: (_) => context.read<EghuIndicatorDetailBloc>().add(
              const EghuIndicatorDetailBasicFileRemoved(),
            ),
            onPickPrint: () =>
                _pickAttachment(context, EghuIndicatorUploadTarget.print),
            onRemovePrintAt: (_) => context.read<EghuIndicatorDetailBloc>().add(
              const EghuIndicatorDetailPrintFileRemoved(),
            ),
            onSubmit: () => context.read<EghuIndicatorDetailBloc>().add(
              const EghuIndicatorDetailSubmitted(),
            ),
          );
        },
      ),
    );

    return _withLoginProfileListener(content);
  }

  LoginState? _readLoginState(BuildContext context) {
    try {
      return context.read<LoginBloc>().state;
    } catch (_) {
      return null;
    }
  }

  void _requestProfileLoad(BuildContext context) {
    if (_profileLoadRequested) return;
    try {
      context.read<LoginBloc>().add(const LoadUserProfile());
      _profileLoadRequested = true;
    } catch (_) {
      // Tests can inject the bloc without an auth provider.
    }
  }

  Widget _withLoginProfileListener(Widget child) {
    try {
      final loginBloc = context.read<LoginBloc>();
      return BlocListener<LoginBloc, LoginState>(
        bloc: loginBloc,
        listenWhen: (previous, current) =>
            previous.user != current.user && current.user != null,
        listener: (context, state) => _syncProfile(state),
        child: child,
      );
    } catch (_) {
      return child;
    }
  }

  void _syncProfile(LoginState state) {
    final user = state.user;
    if (user == null) return;
    _bloc?.add(EghuIndicatorDetailProfileChanged(employeeName: user.username));
  }

  void _onSubmitStateChanged(
    BuildContext context,
    EghuIndicatorDetailState state,
  ) {
    if (state.status == EghuIndicatorDetailStatus.successSaved) {
      showToast(
        context,
        Words.eghuCreateSuccess.tr(),
        backgroundColor: const Color(0xFF17B26A),
      );
      Navigator.of(context).maybePop(true);
      return;
    }

    if (state.status == EghuIndicatorDetailStatus.submitFailure) {
      showToast(context, localizedEghuIndicatorError(state.errorMessage));
    }
  }

  Future<void> _selectConsumer(
    BuildContext context,
    EghuIndicatorDetailState state,
  ) async {
    final selected = await showModalBottomSheet<WorkingWithConsumersList>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuConsumerPickerSheet(
        source: _consumerSource!,
        selected: state.selectedConsumer,
      ),
    );

    if (!context.mounted || selected == null) return;
    context.read<EghuIndicatorDetailBloc>().add(
      EghuIndicatorDetailConsumerSelected(selected),
    );
  }

  Future<void> _selectEghu(
    BuildContext context,
    EghuIndicatorDetailState state,
  ) async {
    final consumer = state.selectedConsumer;
    if (consumer == null) {
      showToast(
        context,
        Words.selectConsumerFirst.tr(),
        backgroundColor: Colors.orange,
      );
      return;
    }

    final selected = await showModalBottomSheet<EghuDeviceSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuDevicePickerSheet(
        source: _consumerSource!,
        consumer: consumer,
        selected: state.selectedEghu,
      ),
    );

    if (!context.mounted || selected == null) return;
    context.read<EghuIndicatorDetailBloc>().add(
      EghuIndicatorDetailEghuSelected(
        selected.item,
        consumerDetail: selected.detail,
      ),
    );
  }

  Future<void> _pickAttachment(
    BuildContext context,
    EghuIndicatorUploadTarget target,
  ) async {
    final attachments = await pickEghuIndicatorAttachments(
      context,
      _imagePicker,
      target,
    );
    if (!context.mounted || attachments.isEmpty) return;

    // Editing an existing indicator replaces the single file in this slot.
    final attachment = attachments.first;
    final bloc = context.read<EghuIndicatorDetailBloc>();
    switch (target) {
      case EghuIndicatorUploadTarget.basic:
        bloc.add(EghuIndicatorDetailBasicFileSet(attachment));
      case EghuIndicatorUploadTarget.print:
        bloc.add(EghuIndicatorDetailPrintFileSet(attachment));
    }
  }
}

class _DetailFailure extends StatelessWidget {
  const _DetailFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EghuActionCreateColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(onPressed: onRetry, child: Text(Words.retry.tr())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
