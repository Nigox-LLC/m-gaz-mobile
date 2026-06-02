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
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../data/models/eghu_removal_detail.dart';
import '../bloc/eghu_action_create_bloc/eghu_action_create_bloc.dart';
import '../bloc/eghu_detach_create_bloc/eghu_detach_create_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/create/eghu_action_upload_widgets.dart';
import '../widgets/create/eghu_create_header.dart';

class EghuDetachCreatePage extends StatefulWidget {
  const EghuDetachCreatePage({
    super.key,
    this.api,
    this.detailApi,
    this.detail,
    this.consumerApi,
    this.consumerSource,
    this.bloc,
  });

  final EghuActionSubmitApi? api;
  final EghuActionDetailApi? detailApi;
  final EghuRemovalDetail? detail;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuDetachCreateBloc? bloc;

  @override
  State<EghuDetachCreatePage> createState() => _EghuDetachCreatePageState();
}

class _EghuDetachCreatePageState extends State<EghuDetachCreatePage> {
  final _otherReasonController = TextEditingController();
  final _imagePicker = ImagePicker();
  EghuDetachCreateBloc? _bloc;
  EghuActionConsumerSource? _consumerSource;
  bool _profileLoadRequested = false;
  _DetachDropdown? _openDropdown;

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
        EghuDetachCreateBloc(
          api: widget.api ?? di.get<EghuActionApi>(),
          detailApi:
              widget.detailApi ??
              (widget.detail != null ? di.get<EghuActionApi>() : null),
          detail: widget.detail,
          employeeId: profile?.user?.employeeId,
          employeeName: profile?.user?.username,
          regionId: profile?.user?.regionId,
          districtId: profile?.user?.districtId,
        );

    if (profile?.user == null) {
      _requestProfileLoad(context);
    } else {
      _syncProfile(profile!);
    }
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider.value(
      value: _bloc!,
      child: BlocConsumer<EghuDetachCreateBloc, EghuDetachCreateState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onSubmitStateChanged,
        builder: (context, state) {
          if (_otherReasonController.text != state.otherReason) {
            _otherReasonController.value = TextEditingValue(
              text: state.otherReason,
              selection: TextSelection.collapsed(
                offset: state.otherReason.length,
              ),
            );
          }
          return Scaffold(
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
                                title: Words.actionEghuDetach.tr(),
                                helpText: Words.eghuCreateHelpTooltip.tr(),
                                helpButtonKey: const Key(
                                  'eghu-detach-help-button',
                                ),
                                helpTooltipKey: const Key(
                                  'eghu-detach-help-tooltip',
                                ),
                              ),
                              const SizedBox(height: 24),
                              EghuSelectorField(
                                label: Words.consumer.tr(),
                                value: state.selectedConsumer == null
                                    ? Words.selectConsumer.tr()
                                    : state.selectedConsumer!.consumers,
                                placeholder: state.selectedConsumer == null,
                                onTap: () => _selectConsumer(context, state),
                              ),
                              const SizedBox(height: 12),
                              EghuSelectorField(
                                label: Words.eghu.tr(),
                                value: state.selectedEghu == null
                                    ? Words.selectEghu.tr()
                                    : eghuTitle(state.selectedEghu!),
                                placeholder: state.selectedEghu == null,
                                onTap: () => _selectEghu(context, state),
                              ),
                              const SizedBox(height: 12),
                              _InlineDropdownField<EghuDetachReason>(
                                key: const Key('eghu-detach-reason-field'),
                                label: Words.reason.tr(),
                                placeholder: Words.selectReason.tr(),
                                value: state.reason,
                                options: EghuDetachReason.values,
                                optionLabel: (value) => value.label,
                                open: _openDropdown == _DetachDropdown.reason,
                                onToggle: () =>
                                    _toggleDropdown(_DetachDropdown.reason),
                                onClear: () => context
                                    .read<EghuDetachCreateBloc>()
                                    .add(const EghuDetachReasonCleared()),
                                onSelected: (value) {
                                  _closeDropdown();
                                  context.read<EghuDetachCreateBloc>().add(
                                    EghuDetachReasonSelected(value),
                                  );
                                },
                              ),
                              if (state.shouldShowOtherReason) ...[
                                const SizedBox(height: 8),
                                _OtherReasonField(
                                  controller: _otherReasonController,
                                  onChanged: (value) => context
                                      .read<EghuDetachCreateBloc>()
                                      .add(EghuDetachOtherReasonChanged(value)),
                                ),
                              ],
                              const SizedBox(height: 12),
                              _InlineDropdownField<EghuDetachSealStatus>(
                                key: const Key('eghu-detach-seal-status-field'),
                                label: Words.sealStatus.tr(),
                                placeholder: Words.selectSealStatus.tr(),
                                value: state.sealStatus,
                                options: EghuDetachSealStatus.values,
                                optionLabel: (value) => value.label,
                                open:
                                    _openDropdown == _DetachDropdown.sealStatus,
                                onToggle: () =>
                                    _toggleDropdown(_DetachDropdown.sealStatus),
                                onClear: () => context
                                    .read<EghuDetachCreateBloc>()
                                    .add(const EghuDetachSealStatusCleared()),
                                onSelected: (value) {
                                  _closeDropdown();
                                  context.read<EghuDetachCreateBloc>().add(
                                    EghuDetachSealStatusSelected(value),
                                  );
                                },
                              ),
                              if (state.shouldShowAct) ...[
                                const SizedBox(height: 16),
                                EghuUploadSection(
                                  slot: EghuActionAttachmentSlot.act,
                                  title: Words.enterAct.tr(),
                                  emptyText: Words.enterAct.tr(),
                                  attachment: state.actFile,
                                  showHelp: true,
                                  uploaderName: state.employeeName,
                                  onAdd: () => _pickAttachment(
                                    context,
                                    _DetachUploadTarget.act,
                                  ),
                                  onRemove: () => context
                                      .read<EghuDetachCreateBloc>()
                                      .add(const EghuDetachActFileRemoved()),
                                ),
                              ],
                              if (state.shouldShowProof) ...[
                                const SizedBox(height: 16),
                                EghuUploadSection(
                                  slot: EghuActionAttachmentSlot.act,
                                  title: Words.proofInformation.tr(),
                                  emptyText: Words.sendProof.tr(),
                                  keyName: 'proof',
                                  attachment: state.proofFile,
                                  showHelp: true,
                                  uploaderName: state.employeeName,
                                  onAdd: () => _pickAttachment(
                                    context,
                                    _DetachUploadTarget.proof,
                                  ),
                                  onRemove: () => context
                                      .read<EghuDetachCreateBloc>()
                                      .add(const EghuDetachProofFileRemoved()),
                                ),
                              ],
                              if (state.shouldShowGasSupplyStopped) ...[
                                const SizedBox(height: 12),
                                _InlineDropdownField<EghuGasSupplyStopped>(
                                  key: const Key(
                                    'eghu-detach-gas-stopped-field',
                                  ),
                                  label: Words.gasSupplyStopped.tr(),
                                  placeholder: Words.selectGasSupplyStopped
                                      .tr(),
                                  value: state.gasSupplyStopped,
                                  options: EghuGasSupplyStopped.values,
                                  optionLabel: (value) => value.label,
                                  open:
                                      _openDropdown ==
                                      _DetachDropdown.gasSupply,
                                  onToggle: () => _toggleDropdown(
                                    _DetachDropdown.gasSupply,
                                  ),
                                  onClear: () =>
                                      context.read<EghuDetachCreateBloc>().add(
                                        const EghuDetachGasSupplyStoppedCleared(),
                                      ),
                                  onSelected: (value) {
                                    _closeDropdown();
                                    context.read<EghuDetachCreateBloc>().add(
                                      EghuDetachGasSupplyStoppedSelected(value),
                                    );
                                  },
                                ),
                              ],
                              if (state.shouldShowStamp) ...[
                                const SizedBox(height: 12),
                                EghuStampSection(
                                  stamps: state.stamps,
                                  employeeName: state.employeeName,
                                  onAdd: () => context
                                      .read<EghuDetachCreateBloc>()
                                      .add(const EghuDetachStampAdded()),
                                  onNumberChanged: (localId, value) =>
                                      context.read<EghuDetachCreateBloc>().add(
                                        EghuDetachStampNumberChanged(
                                          value,
                                          localId: localId,
                                        ),
                                      ),
                                  onDateChanged: (localId, value) =>
                                      context.read<EghuDetachCreateBloc>().add(
                                        EghuDetachStampDateChanged(
                                          value,
                                          localId: localId,
                                        ),
                                      ),
                                  onRemoveUnsaved: (localId) => context
                                      .read<EghuDetachCreateBloc>()
                                      .add(EghuDetachStampRemoved(localId)),
                                ),
                              ],
                              if (state.shouldShowProtocol) ...[
                                const SizedBox(height: 12),
                                EghuUploadSection(
                                  slot: EghuActionAttachmentSlot.act,
                                  title: Words.protocolInformation.tr(),
                                  keyName: 'protocol',
                                  attachment: state.protocolFile,
                                  showHelp: true,
                                  uploaderName: state.employeeName,
                                  onAdd: () => _pickAttachment(
                                    context,
                                    _DetachUploadTarget.protocol,
                                  ),
                                  onRemove: () =>
                                      context.read<EghuDetachCreateBloc>().add(
                                        const EghuDetachProtocolFileRemoved(),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      EghuSubmitBar(
                        enabled: state.canSubmit,
                        loading:
                            state.status == EghuDetachSubmitStatus.submitting,
                        onTap: () => _confirmSubmit(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return _withLoginProfileListener(content);
  }

  void _toggleDropdown(_DetachDropdown dropdown) {
    setState(() {
      _openDropdown = _openDropdown == dropdown ? null : dropdown;
    });
  }

  void _closeDropdown() {
    if (_openDropdown == null) return;
    setState(() => _openDropdown = null);
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
      // Tests can inject the detach bloc without an auth provider.
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

    _bloc?.add(
      EghuDetachProfileChanged(
        employeeId: user.employeeId,
        employeeName: user.username,
        regionId: user.regionId,
        districtId: user.districtId,
      ),
    );
  }

  void _onSubmitStateChanged(
    BuildContext context,
    EghuDetachCreateState state,
  ) {
    if (state.status == EghuDetachSubmitStatus.success) {
      showToast(
        context,
        Words.eghuCreateSuccess.tr(),
        backgroundColor: const Color(0xFF17B26A),
      );
      Navigator.of(context).maybePop(true);
      return;
    }

    if (state.status == EghuDetachSubmitStatus.failure) {
      showToast(context, _localizedErrorMessage(state.errorMessage));
    }
  }

  String _localizedErrorMessage(String message) {
    for (final word in Words.values) {
      if (word.name == message) return word.tr();
    }
    return message;
  }

  Future<void> _selectConsumer(
    BuildContext context,
    EghuDetachCreateState state,
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
    context.read<EghuDetachCreateBloc>().add(
      EghuDetachConsumerSelected(selected),
    );
  }

  Future<void> _selectEghu(
    BuildContext context,
    EghuDetachCreateState state,
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
    context.read<EghuDetachCreateBloc>().add(
      EghuDetachEghuSelected(selected.item, consumerDetail: selected.detail),
    );
  }

  Future<void> _confirmSubmit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => const _DetachConfirmDialog(),
    );
    if (!context.mounted || confirmed != true) return;
    context.read<EghuDetachCreateBloc>().add(const EghuDetachSubmitted());
  }

  Future<void> _pickAttachment(
    BuildContext context,
    _DetachUploadTarget target,
  ) async {
    final source = await showModalBottomSheet<EghuAttachmentSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EghuAttachmentSourceSheet(),
    );

    if (!context.mounted || source == null) return;

    try {
      final attachment = source == EghuAttachmentSource.camera
          ? await _pickFromCamera()
          : await _pickFromDevice();
      if (!context.mounted || attachment == null) return;

      final bloc = context.read<EghuDetachCreateBloc>();
      switch (target) {
        case _DetachUploadTarget.act:
          bloc.add(EghuDetachActFileSet(attachment));
        case _DetachUploadTarget.proof:
          bloc.add(EghuDetachProofFileSet(attachment));
        case _DetachUploadTarget.protocol:
          bloc.add(EghuDetachProtocolFileSet(attachment));
      }
    } catch (e) {
      if (!context.mounted) return;
      showToast(
        context,
        '${Words.filePickFailed.tr()}: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<EghuActionAttachment?> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
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

  Future<EghuActionAttachment?> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return null;

    return EghuActionAttachment(
      path: path,
      name: file.name,
      sizeBytes: file.size == 0 ? await File(path).length() : file.size,
      isImage: _isImage(path),
      sourceLabel: Words.uploadFromPhone.tr(),
      createdAt: DateTime.now(),
    );
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }
}

enum _DetachDropdown { reason, sealStatus, gasSupply }

enum _DetachUploadTarget { act, proof, protocol }

class _InlineDropdownField<T> extends StatelessWidget {
  const _InlineDropdownField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.open,
    required this.onToggle,
    required this.onClear,
    required this.onSelected,
  });

  final String label;
  final String placeholder;
  final T? value;
  final List<T> options;
  final String Function(T value) optionLabel;
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onClear;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final current = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: eghuText(fontSize: 11, lineHeight: 16, letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EghuActionCreateColors.stroke),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      current == null ? placeholder : optionLabel(current),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: eghuText(
                        fontSize: 13,
                        lineHeight: 20,
                        color: current == null
                            ? EghuActionCreateColors.textSub
                            : EghuActionCreateColors.text,
                      ),
                    ),
                  ),
                  if (current == null)
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20)
                  else
                    InkWell(
                      key: Key('${label.toLowerCase()}-clear'),
                      borderRadius: BorderRadius.circular(10),
                      onTap: onClear,
                      child: const Icon(Icons.close_rounded, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (open) ...[
          const SizedBox(height: 4),
          Container(
            key: Key('${label.toLowerCase()}-options'),
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: EghuActionCreateColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: Column(
              children: options.map((option) {
                final selected = option == current;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: selected
                        ? EghuActionCreateColors.stroke
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelected(option),
                      child: Container(
                        height: 36,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          optionLabel(option),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: eghuText(fontSize: 13, lineHeight: 20),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetachConfirmDialog extends StatelessWidget {
  const _DetachConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        key: const Key('eghu-detach-confirm-dialog'),
        width: 350,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: EghuActionCreateColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1F7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Words.saveEnteredDataQuestion.tr(),
              textAlign: TextAlign.center,
              style: eghuText(
                fontSize: 20,
                lineHeight: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Words.saveEnteredDataDescription.tr(),
              textAlign: TextAlign.center,
              style: eghuText(
                fontSize: 15,
                lineHeight: 24,
                color: EghuActionCreateColors.textSub,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton.icon(
                      key: const Key('eghu-detach-confirm-back'),
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: Text(Words.back.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: EghuActionCreateColors.textStrong,
                        textStyle: eghuText(
                          fontSize: 15,
                          lineHeight: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      key: const Key('eghu-detach-confirm-save'),
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(Words.save.tr()),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: EghuActionCreateColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: eghuText(
                          fontSize: 17,
                          lineHeight: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherReasonField extends StatelessWidget {
  const _OtherReasonField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        key: const Key('eghu-detach-other-reason-field'),
        controller: controller,
        onChanged: onChanged,
        style: eghuText(fontSize: 13, lineHeight: 20),
        decoration: InputDecoration(
          hintText: Words.enterReason.tr(),
          hintStyle: eghuText(
            fontSize: 13,
            lineHeight: 20,
            color: EghuActionCreateColors.textSub,
          ),
          filled: true,
          fillColor: EghuActionCreateColors.field,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(EghuActionCreateColors.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _border([Color color = EghuActionCreateColors.stroke]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }
}
