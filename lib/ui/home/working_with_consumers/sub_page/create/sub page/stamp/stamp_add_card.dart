import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import 'package:m_gaz/global_widget/custom_button.dart';
import 'package:m_gaz/global_widget/custom_date_form_field.dart';
import 'package:m_gaz/global_widget/custom_textfield.dart';
import '../../../../../../../../global_widget/global_dropdown.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../global_bloc/global_bloc.dart';
import '../../../../../../../global_bloc/global_event.dart';
import '../../../../../../../global_bloc/global_state.dart';
import '../../widget/egxu_item.dart';

class StampAddCard extends StatefulWidget {
  const StampAddCard({super.key});

  @override
  State<StampAddCard> createState() => _StampAddCardState();
}

class _StampAddCardState extends State<StampAddCard> {
  final stampController = TextEditingController();
  final placeController = TextEditingController();
  final qrController = TextEditingController();
  final selectedDate = TextEditingController();
  GlobalModel? connectionPoint;
  bool isActive = true;

  @override
  void initState() {
    context.read<GlobalBloc>().add(StampInstallationPointsRequested());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cF5F5F5,
      appBar: AppBar(title: Text(Words.stampAdd.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: stampController,
              label: Words.stampNumber.tr(),
            ),

            CustomDateFormField(
              controller: selectedDate,
              title: Words.installedDate.tr(),
            ),

            CustomTextField(
              controller: placeController,
              label: Words.stampLocation.tr(),
            ),

            BlocBuilder<GlobalBloc, GlobalState>(
              builder: (context, state) {
                if (state.isStampInstallationPointsLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return GenericSelectableField<GlobalModel>(
                  title: Words.connectionPoint.tr(),
                  items: state.stampInstallationPoints,
                  selectedItem: connectionPoint,
                  hintText: Words.select.tr(),
                  getTitle: (e) => e.name ?? "",
                  isEqual: (a, b) => a == b,
                  onChanged: (v) => setState(() => connectionPoint = v),
                );
              },
            ),

            CustomTextField(controller: qrController, label: "QR code"),

            _status(),

            const SizedBox(width: 12),
            CustomButton(title: Words.add.tr(), icon: AppTools.add, onTap: _save),
          ],
        ),
      ),
    );
  }

  /// ---------------- SAVE ----------------
  void _save() {
    if (stampController.text.isEmpty || connectionPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Words.fillAllFields.tr())),
      );
      return;
    }

    final stamp = StampModel(
      stampNumber: stampController.text,
      date: selectedDate.text,
      place: placeController.text,
      connectionPoint: connectionPoint!.name ?? "",
      qr: qrController.text,
      isActive: isActive,
    );

    Navigator.pop(context, stamp);
  }

  /// ---------------- UI ----------------

  Widget _status() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Words.stampStatus.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.c1570EF : Colors.grey.shade700,
            ),
          ),
          Tooltip(
            message: isActive ? Words.installed.tr() : Words.notInstalled.tr(),
            child: Switch(
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.c1570EF,
              inactiveThumbColor: AppColors.white,
              inactiveTrackColor: Colors.grey.shade400,
              focusColor: AppColors.c1570EF.withValues(alpha: 0.3),
              hoverColor: AppColors.c1570EF.withValues(alpha: 0.2),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ],
      ),
    );
  }
}
