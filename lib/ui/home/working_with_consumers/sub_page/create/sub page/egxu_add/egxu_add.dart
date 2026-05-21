import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/global_bloc/global_bloc.dart';
import 'package:m_gaz/global_bloc/global_event.dart';
import 'package:m_gaz/global_bloc/global_state.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/models/global/egxu_list_model.dart';
import '../../../../../../../global_widget/app_tools.dart';
import '../../../../../../../global_widget/custom_button.dart';
import '../../../../../../../global_widget/custom_date_form_field.dart';
import '../../../../../../../global_widget/custom_textfield.dart';
import '../../../../../../../global_widget/global_dropdown.dart';
import '../../../../../../../global_widget/global_app_bar.dart';
import '../../../../bloc/consumer_relations_bloc.dart';
import '../../../../bloc/consumer_relations_state.dart';
import '../../widget/egxu_item.dart';

class EgxuAddScreen extends StatefulWidget {
  const EgxuAddScreen({super.key});

  @override
  State<EgxuAddScreen> createState() => _EgxuAddScreenState();
}

class _EgxuAddScreenState extends State<EgxuAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final factory1Ctrl = TextEditingController();
  final factory2Ctrl = TextEditingController();

  EgxuListModel? selectedEgxu;
  String? selectedEgxuError;

  @override
  void initState() {
    context.read<GlobalBloc>().add(EgxuTypesRequested());
    super.initState();
  }

  void _submit() {
    setState(() {
      selectedEgxuError = selectedEgxu == null ? "EGHU turi tanlanmagan" : null;
    });

    if (!_formKey.currentState!.validate() || selectedEgxu == null) return;

    context.read<ConsumerRelationsBloc>().add(
      CheckFactoryExistRequested(
        factory1: factory1Ctrl.text,
        factory2: factory2Ctrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cF5F5F5,
      appBar: CustomGlobalAppBar(title: Words.addEghu.tr()),
      body: BlocConsumer<ConsumerRelationsBloc, ConsumerRelationsState>(
        listener: (context, state) {
          debugPrint("🎧 LISTENER TRIGGERED: factoryStatus=${state.factoryStatus}");

          // Factory check success - factory exists
          if (state.isFactoryExists) {
            debugPrint("❌ FACTORY EXISTS - Dialog ko'rsatiladi");
            _showExistDialog();
            return;
          }

          // Factory check success - factory not exists
          if (state.isFactoryNotExists) {
            debugPrint("✅ FACTORY NOT EXISTS - Pop qilinmoqda");
            Navigator.of(context).pop(
              EgxuItem(
                dateFrom: fromCtrl.text,
                dateTo: toCtrl.text,
                type: selectedEgxu!.name,
                factory1: factory1Ctrl.text,
                factory2: factory2Ctrl.text,
                imagePath: selectedEgxu!.photo,
              ),
            );
            return;
          }

          // Error handling
          if (state.generalStatus == ConsumerGeneralStatus.fail &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.isFactoryChecking;

          return _buildForm(isLoading);
        },
      ),
    );
  }

  Widget _buildForm(bool loading) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CustomDateFormField(
              controller: fromCtrl,
              title: Words.dateFrom.tr(),
            ),
            CustomDateFormField(
              controller: toCtrl,
              title: Words.dateTo.tr(),
              readOnly: true,
            ),

            // ✅ Yangi GlobalState ga mos o'zgartirish
            BlocBuilder<GlobalBloc, GlobalState>(
              builder: (context, state) {
                // Eski: state.status == GlobalStatus.loading
                // Yangi: state.isEgxuTypesLoading
                if (state.isEgxuTypesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ✅ Yangi: state.isEgxuTypesLoaded
                if (state.isEgxuTypesLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenericSelectableField<EgxuListModel>(
                        title: Words.eghuType.tr(),
                        items: state.egxuTypes,
                        selectedItem: selectedEgxu,
                        hintText: Words.select.tr(),
                        getTitle: (e) => e.name,
                        isEqual: (a, b) => a.id == b.id,
                        onChanged: (v) {
                          setState(() {
                            selectedEgxu = v;
                            selectedEgxuError = null;
                          });
                        },
                      ),
                      if (selectedEgxuError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 6),
                          child: Text(
                            selectedEgxuError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                }

                // Fail holati
                if (state.egxuTypesStatus == EgxuTypesStatus.fail) {
                  return Column(
                    children: [
                      Text(state.errorMessage ?? "Xatolik yuz berdi"),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GlobalBloc>().add(EgxuTypesRequested());
                        },
                        child: const Text("Qayta yuklash"),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            CustomTextField(
              label: Words.factoryOne.tr(),
              controller: factory1Ctrl,
            ),
            16.getH(),
            CustomTextField(
              label: Words.factoryTwo.tr(),
              controller: factory2Ctrl,
            ),
            24.getH(),

            loading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: Words.add.tr(),
                icon: AppTools.add,
                onTap: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExistDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(Words.attention.tr()),
        content: Text(Words.factoryNumberExists.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Words.close.tr()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fromCtrl.dispose();
    toCtrl.dispose();
    factory1Ctrl.dispose();
    factory2Ctrl.dispose();
    super.dispose();
  }
}