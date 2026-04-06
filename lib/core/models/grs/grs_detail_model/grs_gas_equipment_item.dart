import 'package:m_gaz/core/models/grs/grs_detail_model/grs_gas_equipment.dart';

class GrsGasEquipmentItem {
  final int? id;
  final GrsGasEquipment? gasEquipment;
  final double? hourlyGasConsumption;
  final int? quantity;

  GrsGasEquipmentItem({
    this.id,
    this.gasEquipment,
    this.hourlyGasConsumption,
    this.quantity,
  });

  factory GrsGasEquipmentItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsGasEquipmentItem();
    return GrsGasEquipmentItem(
      id: json['id'],
      gasEquipment: json['gas_equipment'] != null ? GrsGasEquipment.fromJson(json['gas_equipment']) : null,
      hourlyGasConsumption: (json['hourly_gas_consumption'] as num?)?.toDouble(),
      quantity: json['quantity'],
    );
  }
}
