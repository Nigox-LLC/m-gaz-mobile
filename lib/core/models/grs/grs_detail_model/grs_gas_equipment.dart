class GrsGasEquipment {
  final int? id;
  final String? name;
  final double? hourlyGasConsumption;

  GrsGasEquipment({this.id, this.name, this.hourlyGasConsumption});

  factory GrsGasEquipment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsGasEquipment();
    return GrsGasEquipment(
      id: json['id'],
      name: json['name'],
      hourlyGasConsumption: (json['hourly_gas_consumption'] as num?)?.toDouble(),
    );
  }
}
