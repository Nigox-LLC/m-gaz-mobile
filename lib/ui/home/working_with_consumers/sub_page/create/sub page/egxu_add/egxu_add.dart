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
  bool loading = false;

  @override
  void initState() {
    context.read<GlobalBloc>().add(EgxuTypesRequested());
    super.initState();
  }

  void _submit() {
    setState(() {
      selectedEgxuError = selectedEgxu == null ? "EGXU turi tanlanmagan" : null;
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
      appBar: CustomGlobalAppBar(title: Words.addEgxu.tr()),
      body: BlocListener<ConsumerRelationsBloc, ConsumerRelationsState>(
        listener: (context, state) {
          print("🎧 LISTENER TRIGGERED: ${state.status}"); // Ko'rsatilgan

          if (state.status == ConsumerRelationsStatus.loading) {
            setState(() => loading = true);
            return;
          }

          if (state.status == ConsumerRelationsStatus.success) {
            setState(() => loading = false);

            // ✅ Endi natijani checkingiz kerak
            if (state.factoryExists == true) {
              debugPrint("❌ FACTORY EXISTS - Dialog ko'rsatiladi");
              _showExistDialog();
            } else {
              debugPrint("✅ FACTORY NOT EXISTS - Pop qilinmoqda");
              Navigator.of(context).pop(
                EgxuItem(
                  dateFrom: fromCtrl.text,
                  dateTo: toCtrl.text,
                  type: selectedEgxu!.name,
                  factory1: factory1Ctrl.text,
                  factory2: factory2Ctrl.text,
                  imagePath: selectedEgxu!.photo, // 🔥🔥🔥
                ),
              );
            }
            return;
          }

          if (state.status == ConsumerRelationsStatus.fail) {
            setState(() => loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? Words.errorOccurred.tr())),
            );
          }
        },
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CustomDateFormField(controller: fromCtrl, title: Words.dateFrom.tr()),
            CustomDateFormField(controller: toCtrl, title: Words.dateTo.tr(),readOnly:true),

            BlocBuilder<GlobalBloc, GlobalState>(
              builder: (context, state) {
                if (state.status == GlobalStatus.loading) {
                  return const CircularProgressIndicator();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenericSelectableField<EgxuListModel>(
                      title: Words.egxuType.tr(),
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
              },
            ),

            CustomTextField(label: Words.factoryOne.tr(), controller: factory1Ctrl),
            16.getH(),
            CustomTextField(label: Words.factoryTwo.tr(), controller: factory2Ctrl),
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
}
