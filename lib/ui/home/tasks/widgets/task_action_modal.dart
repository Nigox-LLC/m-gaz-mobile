import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_event.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_state.dart';

import '../../../../core/utils/colors.dart';
import '../../../../global_widget/app_tools.dart';
import 'task_location_picker_screen.dart';

typedef TaskCompletionCallback =
    void Function({
      required int taskId,
      String? filePath,
      double? latitude,
      double? longitude,
    });
typedef TaskCancelCallback =
    void Function({
      required int taskId,
      required String description,
      required String filePath,
    });
typedef TaskLocationAddressResolver =
    Future<String?> Function(Position position);

class TaskActionModal extends StatefulWidget {
  final TaskModel task;
  final TaskCompletionCallback? onComplete;
  final TaskCancelCallback? onCancelTask;
  final Future<Position?> Function()? locationProvider;
  final TaskLocationAddressResolver? locationAddressResolver;

  const TaskActionModal({
    super.key,
    required this.task,
    this.onComplete,
    this.onCancelTask,
    this.locationProvider,
    this.locationAddressResolver,
  });

  @override
  State<TaskActionModal> createState() => _TaskActionModalState();
}

class _TaskActionModalState extends State<TaskActionModal> {
  static const int _maxAttachmentBytes = 10 * 1024 * 1024;

  final ImagePicker _imagePicker = ImagePicker();
  final ValueNotifier<bool> _cancelSubmitting = ValueNotifier<bool>(false);

  _TaskAttachment? _attachment;
  Position? _position;
  String? _locationAddress;
  bool _isCompleting = false;
  bool _isCanceling = false;
  bool _isPreparingAttachment = false;

  bool get _requiresAnswerFile => widget.task.isAnswerFile == true;

  @override
  void dispose() {
    _cancelSubmitting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final windowHeight = MediaQuery.sizeOf(context).height;
            final maxWidth = constraints.maxWidth > 520
                ? 480.0
                : double.infinity;
            final maxHeight = windowHeight * 0.88;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Container(
                key: const Key('task-action-modal'),
                decoration: const BoxDecoration(
                  color: _TaskActionColors.sheet,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SheetHandle(width: 39),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ModalHeader(
                              onClose: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _InfoTile(
                              label: Words.taskSituation.tr(),
                              value: _readable(widget.task.situation),
                            ),
                            const SizedBox(height: 12),
                            _InfoTile(
                              label: Words.taskType.tr(),
                              value: _readable(
                                widget.task.typeTask ?? widget.task.status,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ReadOnlyComment(
                              text: _readable(widget.task.description),
                            ),
                            if (_requiresAnswerFile) ...[
                              const SizedBox(height: 12),
                              _LocationSection(
                                position: _position,
                                address: _locationAddress,
                                onTap: _openLocationPicker,
                              ),
                              if (_attachment != null) ...[
                                const SizedBox(height: 12),
                                _SelectedAttachmentSummary(
                                  attachment: _attachment!,
                                  onRemove: () =>
                                      setState(() => _attachment = null),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    _BottomActions(
                      isCompleting: _isCompleting,
                      onDone: _handleDone,
                      onCancel: () => _handleCancelTodo(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (widget.onComplete != null) {
      return content;
    }

    return BlocListener<TaskBloc, TaskState>(
      listener: _onTaskStateChanged,
      child: content,
    );
  }

  void _onTaskStateChanged(BuildContext context, TaskState state) {
    if (_isCompleting && !state.isCompletingTask) {
      _handleCompleteState(context, state);
      return;
    }

    if (_isCanceling && !state.isCancelingTask) {
      _handleCancelState(context, state);
    }
  }

  void _handleCompleteState(BuildContext context, TaskState state) {
    if (state.status == TaskStatus.success) {
      setState(() => _isCompleting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Words.taskCompleted.tr()),
          backgroundColor: _TaskActionColors.success,
        ),
      );
      return;
    }

    if (state.status == TaskStatus.fail) {
      setState(() => _isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? "Vazifani bajarishda xatolik yuz berdi",
          ),
          backgroundColor: _TaskActionColors.error,
        ),
      );
    }
  }

  void _handleCancelState(BuildContext context, TaskState state) {
    _cancelSubmitting.value = false;

    if (state.status == TaskStatus.success) {
      setState(() => _isCanceling = false);
      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
      if (navigator.canPop()) navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Words.taskCanceled.tr()),
          backgroundColor: _TaskActionColors.success,
        ),
      );
      return;
    }

    if (state.status == TaskStatus.fail) {
      setState(() => _isCanceling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? "Vazifani bekor qilishda xatolik yuz berdi",
          ),
          backgroundColor: _TaskActionColors.error,
        ),
      );
    }
  }

  Future<void> _handleDone() async {
    if (!_requiresAnswerFile) {
      _completeTask();
      return;
    }

    if (_attachment == null) {
      await _showAttachmentRequiredDialog();
      return;
    }

    if (_position == null) {
      _showSnackBar(Words.enterLocation.tr(), Colors.orange);
      return;
    }

    _completeTask();
  }

  void _completeTask() {
    final onComplete = widget.onComplete;
    if (onComplete != null) {
      onComplete(
        taskId: widget.task.id,
        filePath: _attachment?.path,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
      );
      return;
    }

    setState(() => _isCompleting = true);
    context.read<TaskBloc>().add(
      TaskComplete(
        taskId: widget.task.id,
        filePath: _attachment?.path,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
      ),
    );
  }

  Future<void> _showAttachmentRequiredDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _AttachmentRequiredDialog(
          initialAttachment: _attachment,
          isPreparing: _isPreparingAttachment,
          onPick: _pickAttachmentViaSource,
          onRemove: () {
            setState(() => _attachment = null);
          },
          onBack: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            if (_attachment == null) return;
            Navigator.of(dialogContext).pop();
            if (_position == null) {
              _showSnackBar(Words.enterLocation.tr(), Colors.orange);
              return;
            }
            _completeTask();
          },
        );
      },
    );
  }

  Future<_TaskAttachment?> _pickAttachmentViaSource({
    bool updateMainAttachment = true,
  }) async {
    final source = await showModalBottomSheet<_AttachmentSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AttachmentSourceSheet(),
    );

    if (source == null) return null;

    setState(() => _isPreparingAttachment = true);
    try {
      final picked = source == _AttachmentSource.camera
          ? await _pickFromCamera()
          : await _pickFromDevice();

      if (picked == null) return null;
      if (picked.sizeBytes > _maxAttachmentBytes) {
        _showSnackBar(Words.fileTooLarge.tr(), Colors.orange);
        return null;
      }

      if (updateMainAttachment) {
        setState(() => _attachment = picked);
      }
      return picked;
    } catch (e) {
      _showSnackBar(
        "Faylni tanlab bo'lmadi: ${_cleanError(e)}",
        _TaskActionColors.error,
      );
      return null;
    } finally {
      if (mounted) {
        setState(() => _isPreparingAttachment = false);
      }
    }
  }

  Future<_TaskAttachment?> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;

    final size = await image.length();
    return _TaskAttachment(
      path: image.path,
      name: _fileNameFromPath(image.path),
      sizeBytes: size,
      isImage: true,
    );
  }

  Future<_TaskAttachment?> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return null;

    return _TaskAttachment(
      path: path,
      name: file.name,
      sizeBytes: file.size,
      isImage: _isImagePath(path),
    );
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<TaskLocationPickerResult?>(
      MaterialPageRoute(
        builder: (_) => TaskLocationPickerScreen(
          initialPosition: _position,
          initialAddress: _locationAddress,
          locationProvider: widget.locationProvider,
          locationAddressResolver: widget.locationAddressResolver,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _position = result.position;
      _locationAddress = _normalizeLocationAddress(result.address);
    });
  }

  Future<void> _handleCancelTodo() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _CancelTaskDialog(
          isSubmittingListenable: _cancelSubmitting,
          onPick: () => _pickAttachmentViaSource(updateMainAttachment: false),
          onBack: () => Navigator.of(dialogContext).pop(),
          onSubmit: _cancelTask,
        );
      },
    );
  }

  Future<void> _cancelTask(
    String description,
    _TaskAttachment attachment,
  ) async {
    _cancelSubmitting.value = true;

    final onCancelTask = widget.onCancelTask;
    if (onCancelTask != null) {
      onCancelTask(
        taskId: widget.task.id,
        description: description,
        filePath: attachment.path,
      );
      _cancelSubmitting.value = false;
      return;
    }

    setState(() => _isCanceling = true);
    context.read<TaskBloc>().add(
      TaskCancel(
        taskId: widget.task.id,
        description: description,
        filePath: attachment.path,
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _readable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? Words.noData.tr() : trimmed;
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

class _ModalHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _ModalHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            Words.taskAction.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _TaskTextStyles.heading,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _TaskActionColors.soft,
            border: Border.all(color: _TaskActionColors.stroke, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Batafsil", style: _TaskTextStyles.bodyS),
              const SizedBox(width: 4),
              const Icon(
                Icons.help_outline,
                size: 12,
                color: _TaskActionColors.strong,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkResponse(
          onTap: onClose,
          radius: 22,
          child: const Icon(
            Icons.close,
            size: 24,
            color: _TaskActionColors.strong,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _TaskActionColors.soft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 20,
            color: _TaskActionColors.strong,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _TaskTextStyles.bodyS,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _TaskTextStyles.bodyMBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyComment extends StatelessWidget {
  final String text;

  const _ReadOnlyComment({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Words.comment.tr(), style: _TaskTextStyles.labelSub),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
          decoration: BoxDecoration(
            color: _TaskActionColors.field,
            border: Border.all(color: _TaskActionColors.stroke),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: _TaskTextStyles.bodySBold,
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Position? position;
  final String? address;
  final VoidCallback onTap;

  const _LocationSection({
    required this.position,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = position != null;
    final locationText = hasLocation
        ? (address?.trim().isNotEmpty == true
              ? address!.trim()
              : Words.locationUnavailable.tr())
        : Words.enterLocation.tr();

    return Column(
      key: const Key('task-location-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Words.addLocation.tr(), style: _TaskTextStyles.fieldLabel),
        const SizedBox(height: 8),
        InkWell(
          key: const Key('task-location-pick-button'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _TaskActionColors.field,
              border: Border.all(color: _TaskActionColors.stroke),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    locationText,
                    maxLines: hasLocation ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: hasLocation
                        ? _TaskTextStyles.bodyM
                        : _TaskTextStyles.bodyS,
                  ),
                ),
                const SizedBox(width: 8),
                if (hasLocation)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _TaskActionColors.infoLighter,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.navigation,
                      size: 18,
                      color: _TaskActionColors.info,
                    ),
                  )
                else
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _TaskActionColors.infoLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.navigation,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Words.chooseFromMap.tr(),
                          style: _TaskTextStyles.buttonXS,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedAttachmentSummary extends StatelessWidget {
  final _TaskAttachment attachment;
  final VoidCallback onRemove;

  const _SelectedAttachmentSummary({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _TaskActionColors.field,
        border: Border.all(color: _TaskActionColors.stroke),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _AttachmentIcon(attachment: attachment),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _TaskTextStyles.bodySBold,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatBytes(attachment.sizeBytes),
                  style: _TaskTextStyles.bodyXSSub,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool isCompleting;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const _BottomActions({
    required this.isCompleting,
    required this.onDone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _PrimaryActionButton(
              key: const Key('task-done-button'),
              icon: Icons.check,
              label: Words.done.tr(),
              color: _TaskActionColors.success,
              isLoading: isCompleting,
              onTap: onDone,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PrimaryActionButton(
              key: const Key('task-cancel-todo-button'),
              icon: Icons.close,
              label: Words.cancelAction.tr(),
              color: _TaskActionColors.error,
              onTap: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: isLoading ? color.withValues(alpha: 0.55) : color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _TaskTextStyles.buttonL,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentRequiredDialog extends StatefulWidget {
  final _TaskAttachment? initialAttachment;
  final bool isPreparing;
  final Future<_TaskAttachment?> Function() onPick;
  final VoidCallback onRemove;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const _AttachmentRequiredDialog({
    required this.initialAttachment,
    required this.isPreparing,
    required this.onPick,
    required this.onRemove,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<_AttachmentRequiredDialog> createState() =>
      _AttachmentRequiredDialogState();
}

class _AttachmentRequiredDialogState extends State<_AttachmentRequiredDialog> {
  _TaskAttachment? _attachment;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _attachment = widget.initialAttachment;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('task-attachment-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(width: 24),
              const SizedBox(height: 14),
              Text(
                Words.confirmBeforeBasis.tr(),
                textAlign: TextAlign.center,
                style: _TaskTextStyles.heading.copyWith(
                  color: _TaskActionColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isPicking || widget.isPreparing
                    ? const _AttachmentProgressTile()
                    : _attachment == null
                    ? _UploadBasisTile(onTap: _pick)
                    : _AttachmentPreviewGrid(
                        attachment: _attachment!,
                        onAdd: _pick,
                        onRemove: () {
                          widget.onRemove();
                          setState(() => _attachment = null);
                        },
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SecondaryDialogButton(
                      key: const Key('task-dialog-back-button'),
                      label: Words.back.tr(),
                      onTap: widget.onBack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogConfirmButton(
                      enabled: _attachment != null,
                      onTap: widget.onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick() async {
    setState(() => _isPicking = true);
    final picked = await widget.onPick();
    if (!mounted) return;
    setState(() {
      _attachment = picked ?? _attachment;
      _isPicking = false;
    });
  }
}

class _CancelTaskDialog extends StatefulWidget {
  final ValueListenable<bool> isSubmittingListenable;
  final Future<_TaskAttachment?> Function() onPick;
  final VoidCallback onBack;
  final Future<void> Function(String description, _TaskAttachment attachment)
  onSubmit;

  const _CancelTaskDialog({
    required this.isSubmittingListenable,
    required this.onPick,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<_CancelTaskDialog> createState() => _CancelTaskDialogState();
}

class _CancelTaskDialogState extends State<_CancelTaskDialog> {
  final TextEditingController _reasonController = TextEditingController();
  _TaskAttachment? _attachment;
  bool _isPicking = false;
  bool _hasReason = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _reasonController
      ..removeListener(_onReasonChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.viewInsets.bottom -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        48;
    final maxDialogHeight = availableHeight < 280 ? 280.0 : availableHeight;

    return Dialog(
      key: const Key('task-cancel-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 350, maxHeight: maxDialogHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(width: 24),
                const SizedBox(height: 24),
                Text(
                  Words.cancelBeforeBasis.tr(),
                  textAlign: TextAlign.center,
                  style: _TaskTextStyles.heading.copyWith(
                    color: _TaskActionColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _isPicking
                      ? const _AttachmentProgressTile()
                      : _attachment == null
                      ? _UploadBasisTile(dashed: true, onTap: _pick)
                      : _AttachmentPreviewGrid(
                          attachment: _attachment!,
                          onAdd: _pick,
                          onRemove: () {
                            setState(() => _attachment = null);
                          },
                        ),
                ),
                const SizedBox(height: 16),
                _CancelReasonField(controller: _reasonController),
                const SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: widget.isSubmittingListenable,
                  builder: (context, isSubmitting, _) {
                    final canSubmit =
                        _attachment != null && _hasReason && !isSubmitting;
                    return Row(
                      children: [
                        Expanded(
                          child: _SecondaryDialogButton(
                            key: const Key('task-cancel-dialog-back-button'),
                            label: Words.back.tr(),
                            onTap: isSubmitting ? () {} : widget.onBack,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CancelConfirmButton(
                            enabled: canSubmit,
                            isLoading: isSubmitting,
                            onTap: () => _submit(canSubmit),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onReasonChanged() {
    final hasReason = _reasonController.text.trim().isNotEmpty;
    if (hasReason != _hasReason) {
      setState(() => _hasReason = hasReason);
    }
  }

  Future<void> _pick() async {
    setState(() => _isPicking = true);
    final picked = await widget.onPick();
    if (!mounted) return;
    setState(() {
      _attachment = picked ?? _attachment;
      _isPicking = false;
    });
  }

  Future<void> _submit(bool canSubmit) async {
    if (!canSubmit || _attachment == null) return;
    await widget.onSubmit(_reasonController.text.trim(), _attachment!);
  }
}

class _CancelReasonField extends StatelessWidget {
  final TextEditingController controller;

  const _CancelReasonField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('task-cancel-reason-field'),
      controller: controller,
      minLines: 3,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      style: _TaskTextStyles.bodyS.copyWith(
        color: _TaskActionColors.fieldLabel,
      ),
      decoration: InputDecoration(
        hintText: Words.cancelReasonHint.tr(),
        hintStyle: _TaskTextStyles.bodyS.copyWith(
          color: _TaskActionColors.fieldLabel,
        ),
        filled: true,
        fillColor: _TaskActionColors.field,
        contentPadding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _TaskActionColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _TaskActionColors.strokeStrong),
        ),
      ),
    );
  }
}

class _UploadBasisTile extends StatelessWidget {
  final VoidCallback onTap;
  final bool dashed;

  const _UploadBasisTile({required this.onTap, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: 56,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_file, size: 18, color: Colors.black),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              Words.uploadBasis.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _TaskTextStyles.bodyM,
            ),
          ),
        ],
      ),
    );

    return InkWell(
      key: const Key('task-upload-basis-tile'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: dashed
          ? CustomPaint(
              painter: const _DashedRoundedBorderPainter(
                color: _TaskActionColors.strokeStrong,
                radius: 20,
              ),
              child: content,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: _TaskActionColors.strokeStrong),
                borderRadius: BorderRadius.circular(20),
              ),
              child: content,
            ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dashWidth = 5.0;
      const gapWidth = 4.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _AttachmentProgressTile extends StatelessWidget {
  const _AttachmentProgressTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _TaskActionColors.soft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.insert_drive_file_outlined,
            size: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("fayl nomi", style: _TaskTextStyles.bodySBold),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Words.fileSize.tr(),
                      style: _TaskTextStyles.bodyXSSub,
                    ),
                  ),
                  Text("26%", style: _TaskTextStyles.bodyXSSub),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: 0.26,
                  color: _TaskActionColors.strong,
                  backgroundColor: const Color(0xFFDBDBD9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentPreviewGrid extends StatelessWidget {
  final _TaskAttachment attachment;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _AttachmentPreviewGrid({
    required this.attachment,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _AttachmentPreviewTile(attachment: attachment, onRemove: onRemove),
          _AddMoreBasisTile(onTap: onAdd),
        ],
      ),
    );
  }
}

class _AttachmentPreviewTile extends StatelessWidget {
  final _TaskAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentPreviewTile({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('task-attachment-preview-tile'),
      width: 116,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: _TaskActionColors.field,
                  border: Border.all(color: _TaskActionColors.strokeStrong),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: attachment.isImage
                    ? Image.file(
                        File(attachment.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _AttachmentIcon(attachment: attachment),
                      )
                    : Center(child: _AttachmentIcon(attachment: attachment)),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              key: const Key('task-attachment-remove-button'),
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMoreBasisTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMoreBasisTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 116,
        height: 132,
        decoration: BoxDecoration(
          border: Border.all(color: _TaskActionColors.strokeStrong),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTools.svg(
              AppTools.icPaperclip,
              colorFilter: ColorFilter.mode(AppColors.c717680, BlendMode.srcIn),
            ),
            const SizedBox(height: 8),
            Text(
              Words.uploadBasis.tr(),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: _TaskTextStyles.bodyM,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentSourceSheet extends StatelessWidget {
  const _AttachmentSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: _TaskActionColors.sheet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(width: 36),
                const SizedBox(height: 13),
                _SourceOptionTile(
                  icon: Icons.camera_alt_outlined,
                  label: Words.openCamera.tr(),
                  onTap: () => Navigator.pop(context, _AttachmentSource.camera),
                ),
                const SizedBox(height: 8),
                _SourceOptionTile(
                  icon: Icons.create_new_folder_outlined,
                  label: Words.uploadFromPhone.tr(),
                  onTap: () => Navigator.pop(context, _AttachmentSource.device),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _TaskActionColors.soft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _TaskTextStyles.bodyM,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryDialogButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.chevron_left,
          color: _TaskActionColors.textPrimary,
        ),
        label: Text(label, style: _TaskTextStyles.bodyMBold),
      ),
    );
  }
}

class _DialogConfirmButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _DialogConfirmButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PrimaryActionButton(
      icon: Icons.check,
      label: Words.confirm.tr(),
      color: enabled
          ? _TaskActionColors.success
          : _TaskActionColors.successLight,
      onTap: enabled ? onTap : () {},
    );
  }
}

class _CancelConfirmButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _CancelConfirmButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PrimaryActionButton(
      key: const Key('task-cancel-confirm-button'),
      icon: Icons.check,
      label: Words.cancelAction.tr(),
      color: enabled ? _TaskActionColors.error : _TaskActionColors.errorLight,
      isLoading: isLoading,
      onTap: enabled ? onTap : () {},
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final double width;

  const _SheetHandle({required this.width});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: 3,
        decoration: BoxDecoration(
          color: _TaskActionColors.handle,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _AttachmentIcon extends StatelessWidget {
  final _TaskAttachment attachment;

  const _AttachmentIcon({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Icon(
      attachment.isImage
          ? Icons.image_outlined
          : Icons.insert_drive_file_outlined,
      size: 24,
      color: _TaskActionColors.strong,
    );
  }
}

class _TaskAttachment {
  final String path;
  final String name;
  final int sizeBytes;
  final bool isImage;

  const _TaskAttachment({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.isImage,
  });
}

enum _AttachmentSource { camera, device }

class _TaskActionColors {
  static const Color sheet = Color(0xFFFCFCFC);
  static const Color soft = Color(0xFFF0F0F0);
  static const Color field = Color(0xFFF9F9F9);
  static const Color stroke = Color(0xFFE8E8E8);
  static const Color strokeStrong = Color(0xFFD0D5E2);
  static const Color handle = Color(0xFFE1E1E1);
  static const Color strong = Color(0xFF202020);
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSub = Color(0xFFBBBBBB);
  static const Color fieldLabel = Color(0xFF5B6078);
  static const Color success = Color(0xFF1FC16B);
  static const Color successLight = Color(0xFFC2F5DA);
  static const Color error = Color(0xFFE02D2D);
  static const Color errorLight = Color(0xFFFFC0C5);
  static const Color info = Color(0xFF3B72F6);
  static const Color infoLight = Color(0xFFC0D5FF);
  static const Color infoLighter = Color(0xFFEBF1FF);
}

class _TaskTextStyles {
  static final TextStyle heading = GoogleFonts.manrope(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  static final TextStyle bodyM = GoogleFonts.manrope(
    fontSize: 15,
    height: 24 / 15,
    fontWeight: FontWeight.w500,
    color: _TaskActionColors.strong,
  );

  static final TextStyle bodyMBold = GoogleFonts.manrope(
    fontSize: 15,
    height: 24 / 15,
    fontWeight: FontWeight.w800,
    color: _TaskActionColors.strong,
  );

  static final TextStyle bodyS = GoogleFonts.manrope(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w500,
    color: _TaskActionColors.strong,
  );

  static final TextStyle bodySBold = GoogleFonts.manrope(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w700,
    color: _TaskActionColors.strong,
  );

  static final TextStyle labelSub = GoogleFonts.manrope(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w500,
    color: _TaskActionColors.textSub,
  );

  static final TextStyle fieldLabel = GoogleFonts.manrope(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: _TaskActionColors.fieldLabel,
  );

  static final TextStyle bodyXSSub = GoogleFonts.manrope(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: _TaskActionColors.textSub,
  );

  static final TextStyle buttonXS = GoogleFonts.manrope(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: Colors.white,
  );

  static final TextStyle buttonL = GoogleFonts.manrope(
    fontSize: 17,
    height: 28 / 17,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}

String _fileNameFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.split('/').last;
}

bool _isImagePath(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png');
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return "0 KB";
  const kb = 1024;
  const mb = kb * 1024;
  if (bytes >= mb) {
    return "${(bytes / mb).toStringAsFixed(1)} MB";
  }
  return "${(bytes / kb).ceil()} KB";
}

String? _normalizeLocationAddress(String? address) {
  final trimmed = address?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
