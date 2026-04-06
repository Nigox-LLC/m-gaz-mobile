import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/core/utils/style.dart';
import 'package:m_gaz/global_widget/custom_textfield.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/mocdata/map_select_item.dart';
import '../../../../../../../global_bloc/global_bloc.dart';
import '../../../../../../../global_bloc/global_state.dart';
import '../../../../../../../global_widget/global_dropdown.dart';

class StepEgxuList extends StatefulWidget {
  final void Function(Map<String, dynamic>) onDataSaved;

  const StepEgxuList({
    super.key,
    required this.onDataSaved,
  });

  @override
  State<StepEgxuList> createState() => StepEgxuListState();
}

class StepEgxuListState extends State<StepEgxuList> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController monthStart = TextEditingController();
  final TextEditingController extraGas = TextEditingController();
  final TextEditingController violationGas = TextEditingController();
  final TextEditingController remaining = TextEditingController();
  final TextEditingController monthEnd = TextEditingController();
  final TextEditingController diff = TextEditingController();
  final TextEditingController grpLost = TextEditingController();
  final TextEditingController totalGas = TextEditingController();
  final TextEditingController reason = TextEditingController();
  final TextEditingController ghuId = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? activityType;
  String? gasNetwork;
  String? egxuPoint;
  String? disconnected;

  SelectItem? disconnectedReason;
  SelectItem? counterStatus;
  SelectItem? afterEgxuGrp;
  SelectItem? grpExists;

  List<String> images = [];
  List<String> files = [];

  bool submit() {
    if (_formKey.currentState!.validate()) {
      widget.onDataSaved({
        "monthStart": monthStart.text,
        "extraGas": extraGas.text,
        "violationGas": violationGas.text,
        "remaining": remaining.text,
        "monthEnd": monthEnd.text,
        "diff": diff.text,
        "grpExists": grpExists,
        "grpLost": grpLost.text,
        "totalGas": totalGas.text,
        "activityType": activityType,
        "gasNetwork": gasNetwork,
        "egxuPoint": egxuPoint,
        "ghuId": ghuId.text,
        "afterEgxuGrp": afterEgxuGrp,
        "reason": reason.text,
        "counterStatus": counterStatus,
        "disconnected": disconnected,
        "images": images,
        "files": files,
      });
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    monthStart.dispose();
    extraGas.dispose();
    violationGas.dispose();
    remaining.dispose();
    monthEnd.dispose();
    diff.dispose();
    grpLost.dispose();
    totalGas.dispose();
    reason.dispose();
    ghuId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(Words.egxuInfo.tr()),
            _buildTextFields(),
            SizedBox(height: 24.w),
            _buildDropdowns(),
            SizedBox(height: 24.w),
            _buildSectionTitle(Words.images.tr()),
            _buildImageUpload(),
            SizedBox(height: 24.w),
            _buildSectionTitle(Words.files.tr()),
            _buildFileUpload(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.w),
      child: Text(
        title,
        style: AppTextStyles.style600.copyWith(
          fontSize: 16.w,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        CustomTextField(
          controller: monthStart,
          label: Words.monthStartIndicator.tr(),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.w),
        CustomTextField(
          controller: extraGas,
          label: Words.extraGasUsage.tr(),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.w),
        CustomTextField(
          controller: violationGas,
          label: Words.violationGasUsage.tr(),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.w),
        CustomTextField(
          controller: remaining,
          label: Words.additionalResidue.tr(),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.w),
        CustomTextField(
          controller: monthEnd,
          label: Words.monthEndIndicator.tr(),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.w),
        CustomTextField(controller: diff, label: Words.indicatorDifference.tr()),
        SizedBox(height: 12.w),
        CustomTextField(
          controller: grpLost,
          label: Words.grpLoss.tr(),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.w),
        CustomTextField(controller: totalGas, label: Words.totalGasUsage.tr()),
        SizedBox(height: 12.w),
        CustomTextField(controller: ghuId, label: Words.ghuId.tr()),
        SizedBox(height: 12.w),
        CustomTextField(controller: reason, label: Words.violationReason.tr()),
      ],
    );
  }

  Widget _buildDropdowns() {
    return BlocBuilder<GlobalBloc, GlobalState>(
      builder: (context, state) {
        return Column(
          children: [
            GenericSelectableField<SelectItem>(
              title: Words.grpExist.tr(),
              items: grpExistsItems,
              selectedItem: grpExists,
              hintText: Words.select.tr(),
              getTitle: (e) => e.label,
              isEqual: (a, b) => a.code == b.code,
              onChanged: (v) => setState(() => grpExists = v),
            ),
            SizedBox(height: 12.w),
            GenericSelectableField<String>(
              title: Words.activityType.tr(),
              items: state.activityTypes
                  .map((e) => e.name)
                  .whereType<String>()
                  .toList(),
              selectedItem: activityType,
              hintText: state.activityTypes.isEmpty
                  ? Words.loading.tr()
                  : Words.select.tr(),
              getTitle: (e) => e,
              isEqual: (a, b) => a == b,
              onChanged: (v) => setState(() => activityType = v),
            ),
            SizedBox(height: 12.w),
            GenericSelectableField<String>(
              title: Words.gasNetworkName.tr(),
              items: state.gasNetworks
                  .map((e) => e.name)
                  .whereType<String>()
                  .toList(),
              selectedItem: gasNetwork,
              hintText: state.isGasNetworkLoading
                  ? Words.loading.tr()
                  : Words.select.tr(),
              getTitle: (e) => e,
              isEqual: (a, b) => a == b,
              onChanged: (v) => setState(() => gasNetwork = v),
            ),
            SizedBox(height: 12.w),
            GenericSelectableField<String>(
              title: Words.egxuConnectionPoint.tr(),
              items: state.connectionPoints
                  .map((e) => e.name)
                  .whereType<String>()
                  .toList(),
              selectedItem: egxuPoint,
              hintText: state.connectionPoints.isEmpty
                  ? Words.loading.tr()
                  : Words.select.tr(),
              getTitle: (e) => e,
              isEqual: (a, b) => a == b,
              onChanged: (v) => setState(() => egxuPoint = v),
            ),
            SizedBox(height: 12.w),
            GenericSelectableField<SelectItem>(
              title: Words.moveGrpAfterEgxu.tr(),
              items: moveGrpAfterEgxuItems,
              selectedItem: afterEgxuGrp,
              hintText: Words.select.tr(),
              getTitle: (e) => e.label,
              isEqual: (a, b) => a.code == b.code,
              onChanged: (v) => setState(() => afterEgxuGrp = v),
            ),
            SizedBox(height: 12.w),
            GenericSelectableField<SelectItem>(
              title: Words.meterStatus.tr(),
              items: counterStatusItems,
              selectedItem: counterStatus,
              hintText: Words.select.tr(),
              getTitle: (e) => e.label,
              isEqual: (a, b) => a.code == b.code,
              onChanged: (v) => setState(() => counterStatus = v),
            ),
            SizedBox(height: 12.w),
            GenericSelectableField<SelectItem>(
              title: Words.gasNetworkDisconnected.tr(),
              items: gasDisconnectReasons,
              selectedItem: disconnectedReason,
              hintText: Words.select.tr(),
              getTitle: (e) => e.label,
              isEqual: (a, b) => a.code == b.code,
              onChanged: (v) => setState(() => disconnectedReason = v),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageUpload() {
    return Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library_outlined, size: 20),
                SizedBox(width: 8.w),
                Text(
                  Words.egxuIndicatorImages.tr(),
                  style: AppTextStyles.style600.copyWith(fontSize: 14.w),
                ),
              ],
            ),
            SizedBox(height: 8.w),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: [
                ...images.map((e) => _removableImage(e)),
                _addButton(() => _pickImage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUpload() {
    return Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open_outlined, size: 20),
                SizedBox(width: 8.w),
                Text(
                  Words.egxuDailyFiles.tr(),
                  style: AppTextStyles.style600.copyWith(fontSize: 14.w),
                ),
              ],
            ),
            SizedBox(height: 8.w),
            _uploadButton(() => _pickFiles()),
            SizedBox(height: 12.w),
            if (files.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.w),
                itemBuilder: (context, index) {
                  final file = files[index];
                  return _removableFile(file);
                },
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.w),
                child: Center(
                  child: Text(
                    Words.noFilesAdded.tr(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _addButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.w),
          color: Colors.grey.shade50,
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColors.black,
          size: 32.w,
        ),
      ),
    );
  }

  Widget _uploadButton(VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.upload_file, color: AppColors.black, size: 20.w),
      label: Text(
        Words.uploadFile.tr(),
        style: AppTextStyles.style500.copyWith(color: AppColors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
      ),
    );
  }

  Widget _removableImage(String path) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: Image.file(
            File(path),
            width: 80.w,
            height: 80.w,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4.w,
          right: 4.w,
          child: GestureDetector(
            onTap: () => setState(() => images.remove(path)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 18.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _removableFile(String path) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, size: 20, color: AppColors.black),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style500.copyWith(fontSize: 13.w),
                ),
                SizedBox(height: 2.w),
                Text(
                  "${(File(path).lengthSync() / 1024).toStringAsFixed(1)} KB",
                  style: AppTextStyles.style400.copyWith(
                    fontSize: 11.w,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setState(() => files.remove(path)),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() => files.addAll(result.paths.whereType<String>()));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (image != null) setState(() => images.add(image.path));
  }
}

// ========== SelectItem listlari (unchanged) ==========
final List<SelectItem> gasDisconnectReasons = [
  SelectItem(code: "SEASONAL", label: Words.seasonalReason.tr()),
  SelectItem(code: "DEBT", label: Words.debtReason.tr()),
  SelectItem(code: "ACTIVITY_SUSPENDED", label: Words.activitySuspended.tr()),
  SelectItem(
    code: "METER_NOT_CONNECTED",
    label: Words.meterNotConnected.tr(),
  ),
  SelectItem(code: "NO_MODEM_USAGE", label: Words.noModemUsage.tr()),
  SelectItem(code: "TEMPORARY_NOT_USED", label: Words.temporaryNotUsed.tr()),
];

final List<SelectItem> counterStatusItems = [
  SelectItem(code: "Installed", label: Words.installed.tr()),
  SelectItem(code: "TemporarilyDisabled", label: Words.temporarilyDisabled.tr()),
  SelectItem(code: "Untied", label: Words.untied.tr()),
  SelectItem(code: "New", label: Words.newItem.tr()),
];

final List<SelectItem> moveGrpAfterEgxuItems = [
  SelectItem(code: "BEFORE_EGHU", label: Words.beforeEgxu.tr()),
  SelectItem(code: "AFTER_EGHU", label: Words.afterEgxu.tr()),
];

final List<SelectItem> grpExistsItems = [
  SelectItem(code: "True", label: Words.yes.tr()),
  SelectItem(code: "False", label: Words.no.tr()),
];
