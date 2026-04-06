import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/core/utils/style.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/bloc/egxu_create_bloc.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/models/global/global_model.dart';
import '../../../../../../../core/utils/colors.dart';
import '../../../../../../../global_widget/global_dropdown.dart';
import '../../../../bloc/consumer_relations_bloc.dart';
import '../../bloc/egxu_create_event.dart';
import '../../bloc/egxu_create_state.dart';
import '../../sub page/egxu_add/egxu_add.dart';
import '../../sub page/gas_usage/gaz_usage_screen.dart';
import '../../sub page/stamp/stamp_add_card.dart';
import '../../sub page/stamp/stamp_card.dart';
import '../egxu_card_item/egxu_card.dart';
import '../egxu_item.dart';

class StepMainInfo extends StatelessWidget {
  final String regionName;
  final String districtName;
  final List<GlobalModel> consumers;

  const StepMainInfo({
    super.key,
    required this.regionName,
    required this.districtName,
    required this.consumers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsumerCreateBloc, ConsumerCreateState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// INFO CARD
            _buildInfoCard(regionName, districtName),
            24.getH(),

            /// CONSUMER SELECT
            _buildSectionTitle(Words.consumer.tr()),
            8.getH(),
            GenericSelectableField<GlobalModel>(
              title: "", // Hidden title in widget as we show it above
              items: consumers,
              selectedItem: state.selectedConsumer,
              getTitle: (e) => e.name ?? "",
              isEqual: (a, b) => a.id == b.id,
              hintText: Words.selectConsumer.tr(),
              onChanged: (e) =>
                  context.read<ConsumerCreateBloc>().add(ConsumerConsumerSelected(e)),
            ),

            24.getH(),

            /// ================= EGXU =================
            _buildSectionHeader(
              context,
              title: Words.egxu.tr(),
              buttonText: Words.addEgxu.tr(),
              onAdd: () => _addEgxu(context, state),
            ),
            12.getH(),
            state.egxuList.isNotEmpty
                ? EgxuSliderCard(items: state.egxuList)
                : _buildEmptyState(Words.noEgxuAdded.tr(), Icons.list_alt),

            24.getH(),

            /// ================= TAMGA =================
            _buildSectionHeader(
              context,
              title: Words.stamps.tr(),
              buttonText: Words.stampAdd.tr(),
              onAdd: () => _addTamga(context, state),
            ),
            12.getH(),
            state.tamgaList.isNotEmpty
                ? StampCardList(stamps: state.tamgaList)
                : _buildEmptyState(
                    Words.noStampsAdded.tr(), Icons.qr_code_scanner),

            24.getH(),

            /// ================= GAZ SARFI =================
            _buildSectionHeader(
              context,
              title: Words.gasConsumption.tr(),
              buttonText: Words.addGasConsumption.tr(),
              onAdd: () => _openGazUsage(context, state),
            ),
            12.getH(),
            state.gazList.isNotEmpty
                ? Column(
                    children: state.gazList.map((result) {
                      return _gasUsageItem(result);
                    }).toList(),
                  )
                : _buildEmptyState(Words.noGasConsumptionAdded.tr(),
                    Icons.gas_meter_outlined),

            32.getH(),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(String region, String district) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _readOnlyRow(Words.region.tr(), region),
          const Divider(height: 24, thickness: 1, color: AppColors.cF5F5F5),
          _readOnlyRow(Words.district.tr(), district),
        ],
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.style500.copyWith(color: AppColors.c667085),
        ),
        Text(
          value,
          style: AppTextStyles.style600.copyWith(color: AppColors.c101623),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.style600.copyWith(
        fontSize: 14,
        color: AppColors.c344054,
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String buttonText,
    required VoidCallback onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.c1570EF.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 16, color: AppColors.c1570EF),
                4.getW(),
                Text(
                  buttonText,
                  style: AppTextStyles.style600.copyWith(
                    fontSize: 12,
                    color: AppColors.c1570EF,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cEAECF0),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.c1570EF),
          8.getH(),
          Text(
            text,
            style: AppTextStyles.style500.copyWith(
              color: AppColors.c667085,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _gasUsageItem(GazUsageResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cEAECF0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                result.equipment.name??'',
                style: AppTextStyles.style600.copyWith(
                  color: AppColors.c101623,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cECFDF3,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${result.quantity} ta",
                  style:
                      AppTextStyles.style600.copyWith(color: AppColors.c027A48),
                ),
              ),
            ],
          ),
          8.getH(),
          Row(
            children: [
              Icon(Icons.speed, size: 16, color: AppColors.c667085),
              6.getW(),
              Text(
                "${Words.totalConsumption.tr()}: ",
                style: AppTextStyles.style500.copyWith(color: AppColors.c667085),
              ),
              Expanded(
                child: Text(
                  "${result.total.toStringAsFixed(2)} m³/soat",
                  style: AppTextStyles.style600.copyWith(color: AppColors.c344054),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= ACTIONS =================

  Future<void> _addTamga(BuildContext context, ConsumerCreateState state) async {
    final res = await Navigator.push<StampModel>(
      context,
      MaterialPageRoute(builder: (_) => const StampAddCard()),
    );

    if (res != null && context.mounted) {
      context.read<ConsumerCreateBloc>().add(ConsumerTamgaAdded(res));
    }
  }

  Future<void> _addEgxu(BuildContext context, ConsumerCreateState state) async {
    final res = await Navigator.push<EgxuItem>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ConsumerRelationsBloc>(),
          child: const EgxuAddScreen(),
        ),
      ),
    );

    if (res != null && context.mounted) {
      context.read<ConsumerCreateBloc>().add(ConsumerItemAdded(res));
    }
  }

  Future<void> _openGazUsage(BuildContext context, ConsumerCreateState state) async {
    final res = await Navigator.push<GazUsageResult>(
      context,
      MaterialPageRoute(builder: (_) => const GazUsageScreen()),
    );

    if (res != null && context.mounted) {
      context.read<ConsumerCreateBloc>().add(ConsumerGazAdded(res));
    }
  }
}
