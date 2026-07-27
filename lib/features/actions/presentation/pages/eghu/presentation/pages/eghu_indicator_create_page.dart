import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
import '../../../../../data/models/eghu_action_attachment.dart';
import '../bloc/eghu_action_create_bloc/eghu_action_create_bloc.dart';
import '../bloc/eghu_indicator_create_bloc/eghu_indicator_create_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/create/eghu_action_upload_widgets.dart';
import '../widgets/create/eghu_create_header.dart';

class EghuIndicatorCreatePage extends StatefulWidget {
  const EghuIndicatorCreatePage({super.key, this.api, this.consumerApi, this.consumerSource, this.bloc, this.preselection});

  final EghuIndicatorSubmitApi? api;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuIndicatorCreateBloc? bloc;
  final EghuActionPreselection? preselection;

  @override
  State<EghuIndicatorCreatePage> createState() => _EghuIndicatorCreatePageState();
}

class _EghuIndicatorCreatePageState extends State<EghuIndicatorCreatePage> {
  final _valueController = TextEditingController();
  final _imagePicker = ImagePicker();
  EghuIndicatorCreateBloc? _bloc;
  EghuActionConsumerSource? _consumerSource;
  bool _profileLoadRequested = false;
  bool _preselectionApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _consumerSource ??= widget.consumerSource ?? ConsumerRelationsEghuSource(widget.consumerApi ?? di.get<ConsumerRelationsApi>());

    final profile = _readLoginState(context);
    _bloc ??= widget.bloc ?? EghuIndicatorCreateBloc(api: widget.api ?? di.get<EghuIndicatorApi>(), employeeName: profile?.user?.username);

    if (profile?.user == null) {
      _requestProfileLoad(context);
    } else {
      _syncProfile(profile!);
    }

    _applyPreselection();
  }

  void _applyPreselection() {
    final preselection = widget.preselection;
    if (_preselectionApplied || preselection == null) return;
    _preselectionApplied = true;
    _bloc!
      ..add(EghuIndicatorConsumerSelected(preselection.consumer))
      ..add(EghuIndicatorEghuSelected(preselection.eghu, consumerDetail: preselection.detail));
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
      child: BlocConsumer<EghuIndicatorCreateBloc, EghuIndicatorCreateState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onSubmitStateChanged,
        builder: (context, state) {
          syncEghuIndicatorValueController(_valueController, state.value);

          return EghuIndicatorFormView(
            title: Words.actionEghuIndicatorUpload.tr(),
            valueController: _valueController,
            selectedConsumerText: state.selectedConsumer == null ? Words.selectConsumer.tr() : state.selectedConsumer!.consumers,
            selectedConsumerPlaceholder: state.selectedConsumer == null,
            selectedEghuText: state.selectedEghu == null ? Words.selectEghu.tr() : eghuTitle(state.selectedEghu!),
            selectedEghuPlaceholder: state.selectedEghu == null,
            basicFiles: state.basicFiles,
            printFiles: state.printFiles,
            employeeName: state.employeeName,
            canSubmit: state.canSubmit,
            loading: state.status == EghuIndicatorSubmitStatus.submitting,
            onValueChanged: (value) => context.read<EghuIndicatorCreateBloc>().add(EghuIndicatorValueChanged(value)),
            onSelectConsumer: () => _selectConsumer(context, state),
            onSelectEghu: () => _selectEghu(context, state),
            onPickBasic: () => _pickAttachment(context, EghuIndicatorUploadTarget.basic),
            onRemoveBasicAt: (index) => context.read<EghuIndicatorCreateBloc>().add(EghuIndicatorBasicFileRemovedAt(index)),
            onPickPrint: () => _pickAttachment(context, EghuIndicatorUploadTarget.print),
            onRemovePrintAt: (index) => context.read<EghuIndicatorCreateBloc>().add(EghuIndicatorPrintFileRemovedAt(index)),
            onSubmit: () => context.read<EghuIndicatorCreateBloc>().add(const EghuIndicatorSubmitted()),
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
        listenWhen: (previous, current) => previous.user != current.user && current.user != null,
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
    _bloc?.add(EghuIndicatorProfileChanged(employeeName: user.username));
  }

  void _onSubmitStateChanged(BuildContext context, EghuIndicatorCreateState state) {
    if (state.status == EghuIndicatorSubmitStatus.success) {
      showToast(context, Words.eghuCreateSuccess.tr(), backgroundColor: const Color(0xFF17B26A));
      Navigator.of(context).maybePop(true);
      return;
    }

    if (state.status == EghuIndicatorSubmitStatus.failure) {
      showToast(context, localizedEghuIndicatorError(state.errorMessage));
    }
  }

  Future<void> _selectConsumer(BuildContext context, EghuIndicatorCreateState state) async {
    final selected = await showModalBottomSheet<WorkingWithConsumersList>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuConsumerPickerSheet(source: _consumerSource!, selected: state.selectedConsumer),
    );

    if (!context.mounted || selected == null) return;
    context.read<EghuIndicatorCreateBloc>().add(EghuIndicatorConsumerSelected(selected));
  }

  Future<void> _selectEghu(BuildContext context, EghuIndicatorCreateState state) async {
    final consumer = state.selectedConsumer;
    if (consumer == null) {
      showToast(context, Words.selectConsumerFirst.tr(), backgroundColor: Colors.orange);
      return;
    }

    final selected = await showModalBottomSheet<EghuDeviceSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuDevicePickerSheet(source: _consumerSource!, consumer: consumer, selected: state.selectedEghu),
    );

    if (!context.mounted || selected == null) return;
    context.read<EghuIndicatorCreateBloc>().add(EghuIndicatorEghuSelected(selected.item, consumerDetail: selected.detail));
  }

  Future<void> _pickAttachment(BuildContext context, EghuIndicatorUploadTarget target) async {
    final attachments = await pickEghuIndicatorAttachments(context, _imagePicker, target);
    if (!context.mounted || attachments.isEmpty) return;

    final bloc = context.read<EghuIndicatorCreateBloc>();
    for (final attachment in attachments) {
      switch (target) {
        case EghuIndicatorUploadTarget.basic:
          bloc.add(EghuIndicatorBasicFileAdded(attachment));
        case EghuIndicatorUploadTarget.print:
          bloc.add(EghuIndicatorPrintFileAdded(attachment));
      }
    }
  }
}

enum EghuIndicatorUploadTarget { basic, print }

class EghuIndicatorFormView extends StatelessWidget {
  const EghuIndicatorFormView({
    super.key,
    required this.title,
    required this.valueController,
    required this.selectedConsumerText,
    required this.selectedConsumerPlaceholder,
    required this.selectedEghuText,
    required this.selectedEghuPlaceholder,
    required this.basicFiles,
    required this.printFiles,
    required this.employeeName,
    required this.canSubmit,
    required this.loading,
    required this.onValueChanged,
    required this.onSelectConsumer,
    required this.onSelectEghu,
    required this.onPickBasic,
    required this.onRemoveBasicAt,
    required this.onPickPrint,
    required this.onRemovePrintAt,
    required this.onSubmit,
    this.submitLabel,
  });

  final String title;
  final TextEditingController valueController;
  final String selectedConsumerText;
  final bool selectedConsumerPlaceholder;
  final String selectedEghuText;
  final bool selectedEghuPlaceholder;
  final List<EghuActionAttachment> basicFiles;
  final List<EghuActionAttachment> printFiles;
  final String? employeeName;
  final bool canSubmit;
  final bool loading;
  final ValueChanged<String> onValueChanged;
  final VoidCallback onSelectConsumer;
  final VoidCallback onSelectEghu;
  final VoidCallback onPickBasic;
  final void Function(int index) onRemoveBasicAt;
  final VoidCallback onPickPrint;
  final void Function(int index) onRemovePrintAt;
  final VoidCallback onSubmit;
  final String? submitLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: EghuActionCreateColors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EghuCreateHeader(
                          title: title,
                          helpText: Words.eghuCreateHelpTooltip.tr(),
                          helpButtonKey: const Key('eghu-indicator-help-button'),
                          helpTooltipKey: const Key('eghu-indicator-help-tooltip'),
                        ),
                        const SizedBox(height: 24),
                        EghuSelectorField(
                          label: Words.consumer.tr(),
                          value: selectedConsumerText,
                          placeholder: selectedConsumerPlaceholder,
                          onTap: onSelectConsumer,
                        ),
                        const SizedBox(height: 12),
                        EghuSelectorField(label: Words.eghu.tr(), value: selectedEghuText, placeholder: selectedEghuPlaceholder, onTap: onSelectEghu),
                        const SizedBox(height: 12),
                        _IndicatorValueField(controller: valueController, onChanged: onValueChanged),
                        const SizedBox(height: 12),
                        EghuUploadSection(
                          slot: EghuActionAttachmentSlot.act,
                          keyName: 'indicator-basic',
                          title: Words.basisInformation.tr(),
                          attachments: basicFiles,
                          showHelp: true,
                          uploaderName: employeeName,
                          onAdd: onPickBasic,
                          onRemoveAt: onRemoveBasicAt,
                        ),
                        const SizedBox(height: 12),
                        EghuUploadSection(
                          slot: EghuActionAttachmentSlot.act,
                          keyName: 'indicator-print',
                          title: '${Words.printInformation.tr()} (raspetchatka)',
                          attachments: printFiles,
                          showHelp: true,
                          uploaderName: employeeName,
                          onAdd: onPickPrint,
                          onRemoveAt: onRemovePrintAt,
                        ),
                      ],
                    ),
                  ),
                ),
                EghuSubmitBar(enabled: canSubmit, loading: loading, label: submitLabel, onTap: onSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorValueField extends StatelessWidget {
  const _IndicatorValueField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Words.enterValue.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: eghuText(fontSize: 13, lineHeight: 20)),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            key: const Key('eghu-indicator-value-field'),
            controller: controller,
            onChanged: onChanged,
            inputFormatters: const [EghuIndicatorValueInputFormatter()],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: eghuText(fontSize: 13, lineHeight: 20),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: eghuText(fontSize: 13, lineHeight: 20, color: EghuActionCreateColors.textSub),
              suffixText: 'm³',
              suffixStyle: eghuText(fontSize: 13, lineHeight: 20, color: EghuActionCreateColors.textSub),
              filled: true,
              fillColor: EghuActionCreateColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(EghuActionCreateColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border([Color color = EghuActionCreateColors.stroke]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }
}

Future<List<EghuActionAttachment>> pickEghuIndicatorAttachments(BuildContext context, ImagePicker imagePicker, EghuIndicatorUploadTarget target) async {
  final source = await showModalBottomSheet<EghuAttachmentSource>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const EghuAttachmentSourceSheet(),
  );

  if (!context.mounted || source == null) return const [];

  try {
    if (source == EghuAttachmentSource.camera) {
      final image = await _pickFromCamera(imagePicker);
      return image == null ? const [] : [image];
    }
    return await _pickFromDevice(target);
  } catch (e) {
    if (!context.mounted) return const [];
    showToast(context, '${Words.filePickFailed.tr()}: ${e.toString().replaceAll('Exception: ', '')}');
    return const [];
  }
}

Future<EghuActionAttachment?> _pickFromCamera(ImagePicker imagePicker) async {
  final image = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
  if (image == null) return null;

  return EghuActionAttachment(
    path: image.path,
    name: _fileName(image.path),
    sizeBytes: await image.length(),
    isImage: true,
    sourceLabel: Words.openCamera.tr(),
    createdAt: DateTime.now(),
  );
}

Future<List<EghuActionAttachment>> _pickFromDevice(EghuIndicatorUploadTarget target) async {
  // 1. Tizim hamma fayllarni faol ko'rsatishi uchun FileType.any qilamiz
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.any,
    withData: false,
  );

  if (result == null || result.files.isEmpty) return const [];

  // 2. Ruxsat etilgan kengaytmalarni aniqlab olamiz
  final allowedExtensions = (target == EghuIndicatorUploadTarget.basic)
      ? const ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx']
      : const ['xls', 'xlsx', 'fif'];

  final attachments = <EghuActionAttachment>[];

  for (final file in result.files) {
    final path = file.path;
    if (path == null) continue;

    // 3. Fayl kengaytmasini Flutter darajasida tekshiramiz
    final fileExtension = file.extension?.toLowerCase() ?? path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(fileExtension)) {
      continue; // Agar ro'yxatda bo'lmasa, o'tkazib yuboramiz
    }

    // 4. Fayl hajmini tekshirish (ba'zida 0 kelishi mumkin)
    int size = file.size;
    if (size == 0) {
      try {
        size = await File(path).length();
      } catch (_) {
        size = 0; // Faylni o'qishda xatolik bo'lsa
      }
    }

    attachments.add(
      EghuActionAttachment(
        path: path,
        name: file.name,
        sizeBytes: size,
        isImage: _isImage(path),
        sourceLabel: Words.uploadFromPhone.tr(),
        createdAt: DateTime.now(),
      ),
    );
  }

  return attachments;
}

void syncEghuIndicatorValueController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );
}

String localizedEghuIndicatorError(String message) {
  for (final word in Words.values) {
    if (word.name == message) return word.tr();
  }
  return message;
}

String _fileName(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.split('/').last;
}

bool _isImage(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
}
