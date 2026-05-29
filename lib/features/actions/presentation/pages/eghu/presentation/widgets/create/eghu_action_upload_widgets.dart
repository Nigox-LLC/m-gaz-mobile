import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        const SizedBox(height: 8),
        if (_showDetails && attachment != null) ...[
          _UploadInfoPanel(
            slot: widget.slot,
            attachment: attachment,
            uploaderName: widget.uploaderName,
          ),
          const SizedBox(height: 8),
        ],
        if (attachment == null)
          _UploadDropZone(onTap: widget.onAdd)
        else if (attachment.isImage)
          _ImagePreview(attachment: attachment, onRemove: _removeAttachment)
        else
          _FilePreview(attachment: attachment, onRemove: _removeAttachment),
      ],
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EghuActionCreateColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(
            label: 'Yukladi:',
            value: uploadedBy?.isNotEmpty == true
                ? uploadedBy!
                : 'Foydalanuvchi',
          ),
          _InfoLine(label: 'Sanasi:', value: date),
          _InfoLine(label: 'Hajmi:', value: attachment.formattedSize),
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
          fontSize: 13,
          lineHeight: 20,
          color: EghuActionCreateColors.text,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              color: EghuActionCreateColors.textSub,
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
                'Fayl yuborish',
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
  const _ImagePreview({required this.attachment, required this.onRemove});

  final EghuActionAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            key: const Key('eghu-upload-image-preview'),
            height: 160,
            width: double.infinity,
            color: EghuActionCreateColors.field,
            child: attachment.exists
                ? Image.file(File(attachment.path), fit: BoxFit.cover)
                : const Center(child: Icon(Icons.image_outlined, size: 40)),
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
        ],
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  const _FilePreview({required this.attachment, required this.onRemove});

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
