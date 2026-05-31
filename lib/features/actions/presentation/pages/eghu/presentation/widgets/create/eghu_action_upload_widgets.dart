import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../../core/common/words.dart';
import '../../../../../../../../global_widget/app_tools.dart';
import '../../../../../../data/models/eghu_action_attachment.dart';
import '../../bloc/eghu_action_create_bloc.dart';
import 'eghu_action_form_fields.dart';

class EghuUploadSection extends StatefulWidget {
  const EghuUploadSection({
    super.key,
    required this.slot,
    required this.attachment,
    required this.onAdd,
    required this.onRemove,
    this.showHelp = false,
    this.uploaderName,
  });

  final EghuActionAttachmentSlot slot;
  final EghuActionAttachment? attachment;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool showHelp;
  final String? uploaderName;

  @override
  State<EghuUploadSection> createState() => _EghuUploadSectionState();
}

class _EghuUploadSectionState extends State<EghuUploadSection> {
  bool _showDetails = false;

  @override
  void didUpdateWidget(covariant EghuUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.attachment?.path != oldWidget.attachment?.path) {
      _showDetails = false;
    }
  }

  void _removeAttachment() {
    setState(() => _showDetails = false);
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachment;
    final canShowHelp = widget.showHelp && attachment != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EghuSectionHeader(
          title: widget.slot.title,
          onAdd: widget.onAdd,
          showHelp: canShowHelp,
          onHelp: canShowHelp
              ? () => setState(() => _showDetails = !_showDetails)
              : null,
          helpKey: Key('eghu-upload-help-${widget.slot.name}'),
        ),
        if (_showDetails && attachment != null) const _TooltipDot(),
        SizedBox(height: _showDetails && attachment != null ? 2 : 8),
        if (attachment == null)
          _UploadDropZone(onTap: widget.onAdd)
        else if (attachment.isImage)
          _ImagePreview(
            attachment: attachment,
            showDetails: _showDetails,
            slot: widget.slot,
            uploaderName: widget.uploaderName,
            onRemove: _removeAttachment,
          )
        else
          _FilePreview(
            attachment: attachment,
            showDetails: _showDetails,
            slot: widget.slot,
            uploaderName: widget.uploaderName,
            onRemove: _removeAttachment,
          ),
      ],
    );
  }
}

class _TooltipDot extends StatelessWidget {
  const _TooltipDot();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 7,
        height: 12,
        child: Center(
          child: DecoratedBox(
            key: Key('eghu-upload-info-dot'),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 7, height: 7),
          ),
        ),
      ),
    );
  }
}

class _UploadInfoPanel extends StatelessWidget {
  const _UploadInfoPanel({
    required this.slot,
    required this.attachment,
    required this.uploaderName,
  });

  final EghuActionAttachmentSlot slot;
  final EghuActionAttachment attachment;
  final String? uploaderName;

  @override
  Widget build(BuildContext context) {
    final uploadedBy = uploaderName?.trim();
    final date = DateFormat('dd.MM.yyyy HH:mm').format(attachment.createdAt);

    return Container(
      key: Key('eghu-upload-info-${slot.name}'),
      width: 210,
      padding: const EdgeInsets.fromLTRB(12, 9, 13, 11),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1.5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(
            label: '${Words.uploadedBy.tr()}:',
            value: uploadedBy?.isNotEmpty == true
                ? uploadedBy!
                : Words.fallbackUser.tr(),
          ),
          _InfoLine(label: '${Words.fileDate.tr()}:', value: date),
          _InfoLine(
            label: '${Words.fileSizeLabel.tr()}:',
            value: attachment.formattedSize,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: eghuText(
          fontSize: 11,
          lineHeight: 16,
          color: EghuActionCreateColors.text,
          letterSpacing: 0.4,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: eghuText(
              fontSize: 11,
              lineHeight: 16,
              color: EghuActionCreateColors.textSub,
              letterSpacing: 0.4,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  const _UploadDropZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('eghu-upload-drop-zone'),
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTools.svg(AppTools.icPaperclip),
              const SizedBox(width: 8),
              Text(
                Words.sendFile.tr(),
                style: eghuText(fontSize: 15, lineHeight: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.attachment,
    required this.showDetails,
    required this.slot,
    required this.uploaderName,
    required this.onRemove,
  });

  final EghuActionAttachment attachment;
  final bool showDetails;
  final EghuActionAttachmentSlot slot;
  final String? uploaderName;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tooltipLeft = _tooltipLeft(constraints.maxWidth);

        return SizedBox(
          height: 160,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    key: const Key('eghu-upload-image-preview'),
                    color: EghuActionCreateColors.field,
                    child: attachment.exists
                        ? Image.file(File(attachment.path), fit: BoxFit.cover)
                        : const Center(
                            child: Icon(Icons.image_outlined, size: 40),
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: InkWell(
                  key: const Key('eghu-upload-remove-button'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: onRemove,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0x80000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFFFF3434),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: tooltipLeft,
                top: 0,
                child: Visibility(
                  visible: showDetails,
                  maintainState: true,
                  child: _UploadInfoPanel(
                    slot: slot,
                    attachment: attachment,
                    uploaderName: uploaderName,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilePreview extends StatelessWidget {
  const _FilePreview({
    required this.attachment,
    required this.showDetails,
    required this.slot,
    required this.uploaderName,
    required this.onRemove,
  });

  final EghuActionAttachment attachment;
  final bool showDetails;
  final EghuActionAttachmentSlot slot;
  final String? uploaderName;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tooltipLeft = _tooltipLeft(constraints.maxWidth);

        return SizedBox(
          height: 56,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _FilePreviewRow(
                  attachment: attachment,
                  onRemove: onRemove,
                ),
              ),
              Positioned(
                left: tooltipLeft,
                top: 0,
                child: Visibility(
                  visible: showDetails,
                  maintainState: true,
                  child: _UploadInfoPanel(
                    slot: slot,
                    attachment: attachment,
                    uploaderName: uploaderName,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilePreviewRow extends StatelessWidget {
  const _FilePreviewRow({required this.attachment, required this.onRemove});

  final EghuActionAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('eghu-upload-file-preview'),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EghuActionCreateColors.stroke),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: eghuText(fontSize: 13, lineHeight: 20),
                ),
                Text(
                  attachment.formattedSize,
                  style: eghuText(
                    fontSize: 11,
                    lineHeight: 16,
                    color: const Color(0xFF5B6078),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('eghu-upload-file-remove-button'),
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

double _tooltipLeft(double maxWidth) {
  if (maxWidth <= 210) return 0;
  return ((maxWidth - 210) / 2 - 18).clamp(8.0, maxWidth - 210);
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EghuActionCreateColors.strokeStrong
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
