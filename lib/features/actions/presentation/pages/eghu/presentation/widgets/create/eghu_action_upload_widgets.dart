import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../../core/common/words.dart';
import '../../../../../../../../global_widget/app_tools.dart';
import '../../../../../../data/models/eghu_action_attachment.dart';
import '../../bloc/eghu_action_create_bloc/eghu_action_create_bloc.dart';
import 'eghu_action_form_fields.dart';

class EghuUploadSection extends StatefulWidget {
  const EghuUploadSection({
    super.key,
    required this.slot,
    required this.attachments,
    required this.onAdd,
    required this.onRemoveAt,
    this.showHelp = false,
    this.uploaderName,
    this.title,
    this.emptyText,
    this.keyName,
  });

  final EghuActionAttachmentSlot slot;
  final List<EghuActionAttachment> attachments;
  final VoidCallback onAdd;
  final void Function(int index) onRemoveAt;
  final bool showHelp;
  final String? uploaderName;
  final String? title;
  final String? emptyText;
  final String? keyName;

  @override
  State<EghuUploadSection> createState() => _EghuUploadSectionState();
}

class _EghuUploadSectionState extends State<EghuUploadSection> {
  bool _showDetails = false;

  @override
  void didUpdateWidget(covariant EghuUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.attachments.length != oldWidget.attachments.length) {
      _showDetails = false;
    }
  }

  void _removeAt(int index) {
    setState(() => _showDetails = false);
    widget.onRemoveAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final attachments = widget.attachments;
    final canShowHelp = widget.showHelp && attachments.isNotEmpty;
    final keyName = widget.keyName ?? widget.slot.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EghuSectionHeader(
          title: widget.title ?? widget.slot.title,
          onAdd: widget.onAdd,
          showHelp: canShowHelp,
          onHelp: canShowHelp
              ? () => setState(() => _showDetails = !_showDetails)
              : null,
          helpKey: Key('eghu-upload-help-$keyName'),
        ),
        SizedBox(height: 8),
        if (attachments.isEmpty)
          _UploadDropZone(
            onTap: widget.onAdd,
            text: widget.emptyText ?? Words.sendFile.tr(),
          )
        else
          for (var index = 0; index < attachments.length; index++)
            Padding(
              padding: EdgeInsets.only(bottom: index == attachments.length - 1 ? 0 : 8),
              child: attachments[index].isImage
                  ? _ImagePreview(
                      attachment: attachments[index],
                      showDetails: _showDetails,
                      keyName: '$keyName-$index',
                      uploaderName: widget.uploaderName,
                      onRemove: () => _removeAt(index),
                    )
                  : _FilePreview(
                      attachment: attachments[index],
                      showDetails: _showDetails,
                      keyName: '$keyName-$index',
                      uploaderName: widget.uploaderName,
                      onRemove: () => _removeAt(index),
                    ),
            ),
      ],
    );
  }
}

class _UploadInfoPanel extends StatelessWidget {
  const _UploadInfoPanel({
    required this.keyName,
    required this.attachment,
    required this.uploaderName,
  });

  final String keyName;
  final EghuActionAttachment attachment;
  final String? uploaderName;

  @override
  Widget build(BuildContext context) {
    final uploadedBy = uploaderName?.trim();
    final date = DateFormat('dd.MM.yyyy HH:mm').format(attachment.createdAt);

    return Container(
      key: Key('eghu-upload-info-$keyName'),
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
  const _UploadDropZone({required this.onTap, required this.text});

  final VoidCallback onTap;
  final String text;

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
              Text(text, style: eghuText(fontSize: 15, lineHeight: 24)),
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
    required this.keyName,
    required this.uploaderName,
    required this.onRemove,
  });

  final EghuActionAttachment attachment;
  final bool showDetails;
  final String keyName;
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
                    child: attachment.isRemote
                        ? CachedNetworkImage(
                            imageUrl: attachment.remoteUrl!,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    value: progress.progress,
                                    strokeWidth: 2,
                                  ),
                                ),
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.image_outlined, size: 40),
                            ),
                          )
                        : attachment.exists
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
                    keyName: keyName,
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
    required this.keyName,
    required this.uploaderName,
    required this.onRemove,
  });

  final EghuActionAttachment attachment;
  final bool showDetails;
  final String keyName;
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
                    keyName: keyName,
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
