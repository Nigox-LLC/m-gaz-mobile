import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../../../../core/common/words.dart';
import '../../../../core/models/working_with_consumers_document/consumer_file_models.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../features/actions/presentation/pages/eghu/presentation/widgets/eghu_calendar_dialog.dart';

class ConsumerDetailColors {
  const ConsumerDetailColors._();

  static const page = Color(0xFFFCFCFC);
  static const field = Color(0xFFF9F9F9);
  static const soft = Color(0xFFF0F0F0);
  static const stroke = Color(0xFFE8E8E8);
  static const strokeStrong = Color(0xFFD0D5E2);
  static const textStrong = Color(0xFF1A1D2E);
  static const text = Color(0xFF202020);
  static const textSub = Color(0xFFBBBBBB);
  static const primary = Color(0xFF526ED3);
  static const blueChip = Color(0xFF1570EF);
}

TextStyle consumerText({
  required double fontSize,
  required double lineHeight,
  FontWeight fontWeight = FontWeight.w500,
  Color color = ConsumerDetailColors.text,
  double letterSpacing = 0,
}) {
  return GoogleFonts.manrope(
    fontSize: fontSize,
    height: lineHeight / fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

enum ConsumerPickSource { camera, device }

/// Fayl/sertifikat yuklash bo'limi: sarlavha + "Qo'shish" + dropzone yoki fayllar gridi.
class ConsumerUploadSection extends StatefulWidget {
  const ConsumerUploadSection({
    super.key,
    required this.title,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    required this.onView,
    this.helpText,
    this.helpKey,
    this.sectionKey,
  });

  final String title;
  final List<ConsumerUploadFile> files;
  final VoidCallback onAdd;
  final ValueChanged<ConsumerUploadFile> onRemove;
  final ValueChanged<ConsumerUploadFile> onView;
  final String? helpText;
  final Key? helpKey;
  final String? sectionKey;

  @override
  State<ConsumerUploadSection> createState() => _ConsumerUploadSectionState();
}

class _ConsumerUploadSectionState extends State<ConsumerUploadSection> {
  bool _showDetails = false;

  @override
  void didUpdateWidget(covariant ConsumerUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.files != oldWidget.files) {
      _showDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoFile = _infoFile(widget.files);
    final canShowInfo = widget.helpText != null && infoFile != null;
    final keyName = widget.sectionKey ?? 'section';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: consumerText(
                        fontSize: 15,
                        lineHeight: 24,
                        fontWeight: FontWeight.w800,
                        color: ConsumerDetailColors.textStrong,
                      ),
                    ),
                  ),
                  if (canShowInfo) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      key: widget.helpKey,
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _showDetails = !_showDetails),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: ConsumerDetailColors.text,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _AddChip(onTap: widget.onAdd, keyName: widget.sectionKey),
          ],
        ),
        if (_showDetails && infoFile != null) ...[
          const SizedBox(height: 8),
          ConsumerUploadInfoPanel(keyName: keyName, file: infoFile),
        ],
        const SizedBox(height: 10),
        if (widget.files.isEmpty)
          _DropZone(onTap: widget.onAdd, text: Words.addInformation.tr())
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final file in widget.files)
                _FileTile(
                  file: file,
                  onRemove: file.isRemote ? null : () => widget.onRemove(file),
                  onTap: () => widget.onView(file),
                ),
              _AddTile(onTap: widget.onAdd),
            ],
          ),
      ],
    );
  }

  ConsumerUploadFile? _infoFile(List<ConsumerUploadFile> files) {
    if (files.isEmpty) return null;
    final sorted = [...files]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }
}

class ConsumerCertificateDetailsCard extends StatefulWidget {
  const ConsumerCertificateDetailsCard({
    super.key,
    required this.file,
    required this.onChanged,
    this.editable = true,
  });

  final ConsumerUploadFile file;
  final ValueChanged<ConsumerUploadFile> onChanged;
  final bool editable;

  @override
  State<ConsumerCertificateDetailsCard> createState() =>
      _ConsumerCertificateDetailsCardState();
}

class _ConsumerCertificateDetailsCardState
    extends State<ConsumerCertificateDetailsCard> {
  late bool _expanded = widget.editable;

  @override
  Widget build(BuildContext context) {
    final fileKey = widget.file.id ?? widget.file.localPath ?? widget.file.name;

    return Column(
      key: Key('consumer-certificate-details-$fileKey'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: Key('consumer-certificate-details-toggle-$fileKey'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Words.certificateDetails.tr(),
                    style: consumerText(
                      fontSize: 13,
                      lineHeight: 20,
                      fontWeight: FontWeight.w800,
                      color: ConsumerDetailColors.textStrong,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: ConsumerDetailColors.textSub,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          _CertificateField(
            fieldKey: Key('consumer-certificate-number-$fileKey'),
            label: Words.number.tr(),
            value: widget.file.certificateNumber,
            keyboardType: TextInputType.number,
            onChanged: widget.editable
                ? (value) => widget.onChanged(
                    widget.file.copyWith(certificateNumber: value),
                  )
                : null,
          ),
          _CertificateField(
            fieldKey: Key('consumer-certificate-issued-date-$fileKey'),
            label: Words.givenDate.tr(),
            value: widget.file.issuedDate,
            isDate: true,
            onChanged: widget.editable
                ? (value) =>
                      widget.onChanged(widget.file.copyWith(issuedDate: value))
                : null,
          ),
          _CertificateField(
            fieldKey: Key('consumer-certificate-expiry-date-$fileKey'),
            label: Words.endDate.tr(),
            value: widget.file.expiryDate,
            isDate: true,
            onChanged: widget.editable
                ? (value) =>
                      widget.onChanged(widget.file.copyWith(expiryDate: value))
                : null,
          ),
          _CertificateField(
            fieldKey: Key('consumer-certificate-warning-letter-$fileKey'),
            label: Words.warningLetterNumber.tr(),
            value: widget.file.warningLetter,
            keyboardType: TextInputType.number,
            onChanged: widget.editable
                ? (value) => widget.onChanged(
                    widget.file.copyWith(warningLetter: value),
                  )
                : null,
          ),
          _CertificateField(
            fieldKey: Key('consumer-certificate-warning-date-$fileKey'),
            label: Words.warningDate.tr(),
            value: widget.file.warningDate,
            isDate: true,
            onChanged: widget.editable
                ? (value) =>
                      widget.onChanged(widget.file.copyWith(warningDate: value))
                : null,
          ),
          _CertificateField(
            fieldKey: Key('consumer-certificate-warning-reason-$fileKey'),
            label: Words.warningReason.tr(),
            value: widget.file.warningReason,
            bottom: 0,
            onChanged: widget.editable
                ? (value) => widget.onChanged(
                    widget.file.copyWith(warningReason: value),
                  )
                : null,
          ),
        ],
      ],
    );
  }
}

class _CertificateField extends StatelessWidget {
  const _CertificateField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.onChanged,
    this.bottom = 8,
    this.isDate = false,
    this.keyboardType,
  });

  final Key fieldKey;
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final double bottom;
  final bool isDate;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              color: ConsumerDetailColors.textSub,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          isDate
              ? _CertificateDateField(
                  key: fieldKey,
                  value: value,
                  enabled: onChanged != null,
                  onChanged: onChanged,
                )
              : TextFormField(
                  key: fieldKey,
                  initialValue: value ?? '',
                  readOnly: onChanged == null,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  style: consumerText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w500,
                    color: ConsumerDetailColors.textStrong,
                  ),
                  decoration: InputDecoration(
                    hintText: '-',
                    hintStyle: consumerText(
                      fontSize: 13,
                      lineHeight: 20,
                      color: ConsumerDetailColors.textSub,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: _certificateBorder(),
                    enabledBorder: _certificateBorder(),
                    focusedBorder: _certificateBorder(
                      ConsumerDetailColors.primary,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _CertificateDateField extends StatelessWidget {
  const _CertificateDateField({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String? value;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = AppDateFormatter.dateFromString(value, fallback: '-');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: !enabled || onChanged == null
            ? null
            : () async {
                final picked = await pickEghuDate(
                  context,
                  initialDate:
                      AppDateFormatter.parseDate(value) ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  onChanged!(DateFormat('yyyy-MM-dd').format(picked));
                }
              },
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ConsumerDetailColors.stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: consumerText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w500,
                    color: displayValue == '-'
                        ? ConsumerDetailColors.textSub
                        : ConsumerDetailColors.textStrong,
                  ),
                ),
              ),
              AppTools.svg(AppTools.icCalendar, width: 18, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _certificateBorder([
  Color color = ConsumerDetailColors.stroke,
]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}

class ConsumerUploadInfoPanel extends StatelessWidget {
  const ConsumerUploadInfoPanel({
    super.key,
    required this.keyName,
    required this.file,
    this.uploaderName,
  });

  final String keyName;
  final ConsumerUploadFile file;
  final String? uploaderName;

  @override
  Widget build(BuildContext context) {
    final uploadedBy = uploaderName?.trim();
    final date = DateFormat('dd.MM.yyyy HH:mm').format(file.createdAt);

    return Container(
      key: Key('consumer-upload-info-$keyName'),
      width: 210,
      padding: const EdgeInsets.fromLTRB(12, 9, 13, 11),
      decoration: BoxDecoration(
        color: ConsumerDetailColors.field,
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
            value: file.formattedSize.isEmpty ? '-' : file.formattedSize,
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
        style: consumerText(
          fontSize: 11,
          lineHeight: 16,
          color: ConsumerDetailColors.text,
          letterSpacing: 0.4,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              color: ConsumerDetailColors.textSub,
              letterSpacing: 0.4,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap, this.keyName});

  final VoidCallback onTap;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keyName == null ? null : Key('consumer-upload-add-$keyName'),
      decoration: BoxDecoration(
        color: ConsumerDetailColors.soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ConsumerDetailColors.stroke, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 12,
                  color: ConsumerDetailColors.text,
                ),
                const SizedBox(width: 4),
                Text(
                  Words.add.tr(),
                  style: consumerText(fontSize: 13, lineHeight: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ConsumerUnsavedChangesAction { discard, save }

class ConsumerUnsavedChangesSheet extends StatelessWidget {
  const ConsumerUnsavedChangesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          key: const Key('consumer-unsaved-exit-sheet'),
          constraints: const BoxConstraints(maxWidth: 390),
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: ConsumerDetailColors.page,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F7),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    Words.unsavedChangesTitle.tr(),
                    textAlign: TextAlign.center,
                    style: consumerText(
                      fontSize: 20,
                      lineHeight: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Words.unsavedChangesDescription.tr(),
                    textAlign: TextAlign.center,
                    style: consumerText(
                      fontSize: 15,
                      lineHeight: 24,
                      color: ConsumerDetailColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextButton.icon(
                            key: const Key('consumer-unsaved-discard'),
                            onPressed: () => Navigator.of(
                              context,
                            ).pop(ConsumerUnsavedChangesAction.discard),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: Text(Words.logout.tr()),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFB3748),
                              textStyle: consumerText(
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
                            key: const Key('consumer-unsaved-save'),
                            onPressed: () => Navigator.of(
                              context,
                            ).pop(ConsumerUnsavedChangesAction.save),
                            icon: const Icon(Icons.check_rounded, size: 20),
                            label: Text(Words.save.tr()),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: ConsumerDetailColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: consumerText(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.onTap, required this.text});

  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('consumer-upload-drop-zone'),
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
              Text(text, style: consumerText(fontSize: 15, lineHeight: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(radius: 16),
        child: const SizedBox(
          width: 80,
          height: 80,
          child: Icon(
            Icons.add_rounded,
            size: 26,
            color: ConsumerDetailColors.strokeStrong,
          ),
        ),
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.onTap, this.onRemove});

  final ConsumerUploadFile file;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: ConsumerDetailColors.field,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ConsumerDetailColors.stroke),
                  ),
                  child: _preview(),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                right: -6,
                top: -6,
                child: GestureDetector(
                  key: const Key('consumer-file-remove'),
                  onTap: onRemove,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3434),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    if (file.isImage) {
      if (file.isRemote) {
        return CachedNetworkImage(
          imageUrl: file.remoteUrl!,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (_, __, progress) => Center(
            child: CircularProgressIndicator(
              value: progress.progress,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (_, __, ___) => const _FileGlyph(),
        );
      }
      if (file.existsLocal) {
        return Image.file(File(file.localPath!), fit: BoxFit.cover);
      }
    }
    return _FileGlyph(name: file.name);
  }
}

class _FileGlyph extends StatelessWidget {
  const _FileGlyph({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final ext = _ext(name);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.insert_drive_file_outlined,
          size: 26,
          color: ConsumerDetailColors.primary,
        ),
        if (ext != null) ...[
          const SizedBox(height: 2),
          Text(
            ext,
            style: consumerText(
              fontSize: 9,
              lineHeight: 12,
              fontWeight: FontWeight.w700,
              color: ConsumerDetailColors.textSub,
            ),
          ),
        ],
      ],
    );
  }

  String? _ext(String? name) {
    if (name == null || !name.contains('.')) return null;
    final ext = name.split('.').last.split('?').first.toUpperCase();
    return ext.length > 5 ? null : ext;
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({this.radius = 20});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ConsumerDetailColors.strokeStrong
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
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

/// Kamera / telefondan yuklash tanlovi.
class ConsumerSourceSheet extends StatelessWidget {
  const ConsumerSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ConsumerDetailColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _SourceTile(
              icon: AppTools.svg(AppTools.icCamera),
              label: Words.openCamera.tr(),
              onTap: () => Navigator.of(context).pop(ConsumerPickSource.camera),
            ),
            const SizedBox(height: 8),
            _SourceTile(
              icon: AppTools.svg(AppTools.icFolderPlus),
              label: Words.uploadFromPhone.tr(),
              onTap: () => Navigator.of(context).pop(ConsumerPickSource.device),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ConsumerDetailColors.field,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Icon(icon, size: 22, color: ConsumerDetailColors.primary),
              icon,
              const SizedBox(width: 14),
              Text(
                label,
                style: consumerText(
                  fontSize: 15,
                  lineHeight: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
