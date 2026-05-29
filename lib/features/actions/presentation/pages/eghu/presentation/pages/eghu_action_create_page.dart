import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../../../../core/extension/message_extension.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../../../di.dart';
import '../../../../../../../features/auth/presentation/bloc/login_bloc.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../domain/entities/action_menu_item.dart';
import '../bloc/eghu_action_create_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/create/eghu_action_upload_widgets.dart';

class EghuActionCreatePage extends StatefulWidget {
  const EghuActionCreatePage({
    super.key,
    required this.actionType,
    this.api,
    this.consumerApi,
    this.consumerSource,
    this.bloc,
  });

  final ActionMenuType actionType;
  final EghuActionSubmitApi? api;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuActionCreateBloc? bloc;

  @override
  State<EghuActionCreatePage> createState() => _EghuActionCreatePageState();
}

class _EghuActionCreatePageState extends State<EghuActionCreatePage> {
  final _stampController = TextEditingController();
  final _imagePicker = ImagePicker();
  EghuActionCreateBloc? _bloc;
  EghuActionConsumerSource? _consumerSource;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _consumerSource ??=
        widget.consumerSource ??
        ConsumerRelationsEghuSource(
          widget.consumerApi ?? di.get<ConsumerRelationsApi>(),
        );

    if (_bloc != null) return;

    final profile = _readLoginState(context);
    _bloc =
        widget.bloc ??
        EghuActionCreateBloc(
          actionType: widget.actionType,
          api: widget.api ?? di.get<EghuActionApi>(),
          employeeId: profile?.user?.employeeId,
          employeeName: profile?.user?.username,
          regionId: profile?.user?.regionId,
          districtId: profile?.user?.districtId,
        );
  }

  @override
  void dispose() {
    _stampController.dispose();
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc!,
      child: BlocConsumer<EghuActionCreateBloc, EghuActionCreateState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onSubmitStateChanged,
        builder: (context, state) {
          if (_stampController.text != state.stampNumber) {
            _stampController.value = TextEditingValue(
              text: state.stampNumber,
              selection: TextSelection.collapsed(
                offset: state.stampNumber.length,
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
                              _CreateHeader(title: _title),
                              const SizedBox(height: 24),
                              EghuSelectorField(
                                label: "Iste'molchi",
                                value: state.selectedConsumer == null
                                    ? "Iste'molchini tanlang"
                                    : state.selectedConsumer!.consumers,
                                onTap: () => _selectConsumer(context, state),
                              ),
                              const SizedBox(height: 12),
                              EghuSelectorField(
                                label: 'EGHU',
                                value: state.selectedEghu == null
                                    ? "EGHU tanlang"
                                    : eghuTitle(state.selectedEghu!),
                                onTap: () => _selectEghu(context, state),
                              ),
                              const SizedBox(height: 16),
                              EghuUploadSection(
                                slot: EghuActionAttachmentSlot.act,
                                attachment: state.actFile,
                                showHelp: true,
                                uploaderName: state.employeeName,
                                onAdd: () => _pickAttachment(
                                  context,
                                  EghuActionAttachmentSlot.act,
                                ),
                                onRemove: () =>
                                    context.read<EghuActionCreateBloc>().add(
                                      const EghuActionAttachmentRemoved(
                                        EghuActionAttachmentSlot.act,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              EghuStampSection(
                                controller: _stampController,
                                employeeName: state.employeeName,
                                selectedDate: state.stampDateTime,
                                onNumberChanged: (value) => context
                                    .read<EghuActionCreateBloc>()
                                    .add(EghuActionStampNumberChanged(value)),
                                onPickDate: () =>
                                    _pickStampDate(context, state),
                              ),
                              const SizedBox(height: 16),
                              EghuUploadSection(
                                slot: EghuActionAttachmentSlot.comparison,
                                attachment: state.comparisonFile,
                                showHelp: true,
                                uploaderName: state.employeeName,
                                onAdd: () => _pickAttachment(
                                  context,
                                  EghuActionAttachmentSlot.comparison,
                                ),
                                onRemove: () =>
                                    context.read<EghuActionCreateBloc>().add(
                                      const EghuActionAttachmentRemoved(
                                        EghuActionAttachmentSlot.comparison,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      EghuSubmitBar(
                        enabled: state.canSubmit,
                        loading:
                            state.status == EghuActionSubmitStatus.submitting,
                        onTap: () => context.read<EghuActionCreateBloc>().add(
                          const EghuActionSubmitted(),
                        ),
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
  }

  String get _title => switch (widget.actionType) {
    ActionMenuType.reinstall => "EGHU qayta o'rnatish",
    ActionMenuType.detach => 'EGHU yechib olish',
    ActionMenuType.indicatorUpload => "EGHU ko'rsatkichi yuklash",
  };

  LoginState? _readLoginState(BuildContext context) {
    try {
      return context.read<LoginBloc>().state;
    } catch (_) {
      return null;
    }
  }

  void _onSubmitStateChanged(
    BuildContext context,
    EghuActionCreateState state,
  ) {
    if (state.status == EghuActionSubmitStatus.success) {
      showToast(
        context,
        "Ma'lumotlar muvaffaqiyatli yuborildi",
        backgroundColor: const Color(0xFF17B26A),
      );
      Navigator.of(context).maybePop();
      return;
    }

    if (state.status == EghuActionSubmitStatus.failure) {
      showToast(context, state.errorMessage);
    }
  }

  Future<void> _selectConsumer(
    BuildContext context,
    EghuActionCreateState state,
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
    context.read<EghuActionCreateBloc>().add(
      EghuActionConsumerSelected(selected),
    );
  }

  Future<void> _selectEghu(
    BuildContext context,
    EghuActionCreateState state,
  ) async {
    final consumer = state.selectedConsumer;
    if (consumer == null) {
      showToast(
        context,
        "Avval iste'molchini tanlang",
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
    context.read<EghuActionCreateBloc>().add(
      EghuActionEghuSelected(selected.item, consumerDetail: selected.detail),
    );
  }

  Future<void> _pickAttachment(
    BuildContext context,
    EghuActionAttachmentSlot slot,
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

      context.read<EghuActionCreateBloc>().add(
        EghuActionAttachmentSet(slot: slot, file: attachment),
      );
    } catch (e) {
      if (!context.mounted) return;
      showToast(
        context,
        "Faylni tanlab bo'lmadi: ${e.toString().replaceAll('Exception: ', '')}",
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
      sourceLabel: 'Kamera',
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
      sourceLabel: 'Telefon xotirasi',
      createdAt: DateTime.now(),
    );
  }

  Future<void> _pickStampDate(
    BuildContext context,
    EghuActionCreateState state,
  ) async {
    final initial = state.stampDateTime ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!context.mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!context.mounted || time == null) return;

    context.read<EghuActionCreateBloc>().add(
      EghuActionStampDateChanged(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
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

class _CreateHeader extends StatelessWidget {
  const _CreateHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left_rounded),
            color: EghuActionCreateColors.textStrong,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 17,
                height: 28 / 17,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline_rounded),
            color: EghuActionCreateColors.textStrong,
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
        ],
      ),
    );
  }
}
