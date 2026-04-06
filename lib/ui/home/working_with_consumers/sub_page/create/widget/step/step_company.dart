import 'package:flutter/material.dart';
import 'package:m_gaz/global_widget/custom_date_form_field.dart';
import 'package:m_gaz/global_widget/custom_textfield.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../global_widget/global_dropdown.dart';
import '../../../../../../../global_widget/phone_number_input.dart';

class StepCompany extends StatefulWidget {
  final void Function(Map<String, dynamic>) onDataSaved;

  const StepCompany({
    super.key,
    required this.onDataSaved,
  });

  @override
  State<StepCompany> createState() => StepCompanyState();
}

class StepCompanyState extends State<StepCompany> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController contractNumber = TextEditingController();
  final TextEditingController directorName = TextEditingController();
  final TextEditingController stirNumber = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();

  // Date fields
  final TextEditingController contractDateCtrl = TextEditingController();
  final TextEditingController contractEndDateCtrl = TextEditingController();

  // Dropdown fields
  String? consumerType;
  String? direction;
  String? ministry;
  String? grsDevice;
  String? egxuCollector;
  String? egxuTechDevice;
  String? grpType;
  String? settlement;
  String? season;

  bool submit() {
    if (_formKey.currentState!.validate()) {
      widget.onDataSaved({
        "accountNumber": accountNumber.text,
        "contractNumber": contractNumber.text,
        "contractDate": contractDateCtrl.text,
        "contractEndDate": contractEndDateCtrl.text,
        "directorName": directorName.text,
        "stirNumber": stirNumber.text,
        "phone": phone.text,
        "email": email.text,
        "address": address.text,
        "consumerType": consumerType,
        "direction": direction,
        "ministry": ministry,
        "grsDevice": grsDevice,
        "egxuCollector": egxuCollector,
        "egxuTechDevice": egxuTechDevice,
        "grpType": grpType,
        "settlement": settlement,
        "season": season,
      });
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    accountNumber.dispose();
    contractNumber.dispose();
    directorName.dispose();
    stirNumber.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    contractDateCtrl.dispose();
    contractEndDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
              controller: accountNumber, label: Words.accountNumber.tr()),
          CustomTextField(
              controller: contractNumber, label: Words.contractNumber.tr()),
          CustomDateFormField(
            title: Words.contractDate.tr(),
            controller: contractDateCtrl,
          ),
          CustomDateFormField(
            title: Words.contractExpiry.tr(),
            controller: contractEndDateCtrl,
          ),
          CustomTextField(
              controller: directorName, label: Words.directorName.tr()),
          CustomTextField(
              controller: stirNumber, label: Words.companyStir.tr()),
          PhoneNumberInput(controller: phone),
          CustomTextField(controller: email, label: Words.email.tr()),
          CustomTextField(controller: address, label: Words.address.tr()),
          GenericSelectableField<String>(
            title: Words.consumerType.tr(),
            items: const ["Turi 1", "Turi 2"],
            selectedItem: consumerType,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => consumerType = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
            validator: (v) => v == null ? Words.select.tr() : null,
          ),
          GenericSelectableField<String>(
            title: Words.direction.tr(),
            items: const ["Yo'nalish 1", "Yo'nalish 2"],
            selectedItem: direction,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => direction = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
            validator: (v) => v == null ? Words.select.tr() : null,
          ),
          GenericSelectableField<String>(
            title: Words.ministries.tr(),
            items: const ["Vazirlik 1", "Vazirlik 2"],
            selectedItem: ministry,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => ministry = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
          GenericSelectableField<String>(
            title: Words.grsMeasuringDevices.tr(),
            items: const ["GRS 1", "GRS 2"],
            selectedItem: grsDevice,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => grsDevice = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
          GenericSelectableField<String>(
            title: Words.egxuIndustrial.tr(),
            items: const ["Kol 1", "Kol 2"],
            selectedItem: egxuCollector,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => egxuCollector = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
          GenericSelectableField<String>(
            title: Words.egxuTechnological.tr(),
            items: const ["Tech 1", "Tech 2"],
            selectedItem: egxuTechDevice,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => egxuTechDevice = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
          GenericSelectableField<String>(
            title: Words.grpTypes.tr(),
            items: const ["GRP 1", "GRP 2"],
            selectedItem: grpType,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => grpType = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
          GenericSelectableField<String>(
            title: Words.settlement.tr(),
            items: const ["Punkt 1", "Punkt 2"],
            selectedItem: settlement,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => settlement = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
          GenericSelectableField<String>(
            title: Words.season.tr(),
            items: const ["Qish", "Yoz", "Bahor", "Kuz"],
            selectedItem: season,
            hintText: Words.select.tr(),
            onChanged: (v) => setState(() => season = v),
            getTitle: (v) => v,
            isEqual: (a, b) => a == b,
          ),
        ],
      ),
    );
  }
}
