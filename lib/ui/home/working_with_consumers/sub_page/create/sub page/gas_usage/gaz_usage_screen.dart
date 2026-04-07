  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/global_widget/custom_button.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/models/grs/grs_detail_model/grs_gas_equipment.dart';
import '../../../../../../../global_bloc/global_bloc.dart';
import '../../../../../../../global_bloc/global_event.dart';
import '../../../../../../../global_bloc/global_state.dart';
import '../../../../../../../global_widget/global_app_bar.dart';
import '../../../../../../../global_widget/global_dropdown.dart';
import '../../widget/egxu_item.dart';

class GazUsageScreen extends StatefulWidget {
  const GazUsageScreen({super.key});

  @override
  State<GazUsageScreen> createState() => _GazUsageScreenState();
}

class _GazUsageScreenState extends State<GazUsageScreen> {
  GrsGasEquipment? selectedEquipment;
  int quantity = 1;
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocus = FocusNode();

  double get total => (selectedEquipment?.hourlyGasConsumption ?? 0) * quantity;

  @override
  void initState() {
    super.initState();
    context.read<GlobalBloc>().add(GasEquipmentFetched());
    _quantityController.text = quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1) {
      setState(() {
        quantity = newQuantity;
        _quantityController.text = quantity.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cF5F5F5,
      appBar: CustomGlobalAppBar(title: Words.gasConsumption.tr()),
      body: BlocBuilder<GlobalBloc, GlobalState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ================= EQUIPMENT =================
                Card(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GenericSelectableField<GrsGasEquipment>(
                      title: Words.gasAppliance.tr(),
                      hintText: Words.select.tr(),
                      items: state.gasEquipment,
                      selectedItem: selectedEquipment,
                      getTitle: (e) =>
                          "${e.name} (${e.hourlyGasConsumption} m³/soat)",
                      isEqual: (a, b) => a.id == b.id,
                      onChanged: (v) => setState(() => selectedEquipment = v),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ================= HISOB =================
                Card(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow(
                          "1 ${Words.hourlyGasConsumption.tr()}",
                          // "1 soatlik sarf" approx or "hourly consumption"
                          "${selectedEquipment?.hourlyGasConsumption ?? 0} m³",
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Words.quantity.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _buildCounterButton(Icons.remove, () {
                                    if (quantity > 1) {
                                      _updateQuantity(quantity - 1);
                                    }
                                  }),
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: _quantityController,
                                      focusNode: _quantityFocus,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        final newQuantity = int.tryParse(value);
                                        if (newQuantity != null &&
                                            newQuantity >= 1) {
                                          setState(() {
                                            quantity = newQuantity;
                                          });
                                        }
                                      },
                                      onSubmitted: (value) {
                                        final newQuantity =
                                            int.tryParse(value) ?? 1;
                                        _updateQuantity(newQuantity);
                                      },
                                    ),
                                  ),
                                  _buildCounterButton(Icons.add, () {
                                    _updateQuantity(quantity + 1);
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        _infoRow(
                          Words.total.tr(),
                          "${total.toStringAsFixed(2)} m³",
                          isBold: false,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= SAVE =================
                CustomButton(
                  title: Words.add.tr(),
                  onTap: selectedEquipment == null
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            GazUsageResult(
                              equipment: selectedEquipment!,
                              quantity: quantity,
                              total: total,
                            ),
                          );
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isBold ? AppColors.black : AppColors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 15,
            color: isBold ? AppColors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: AppColors.black),
        ),
      ),
    );
  }
}
