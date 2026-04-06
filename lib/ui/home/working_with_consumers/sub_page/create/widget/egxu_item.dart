import '../../../../../../core/models/grs/grs_detail_model/grs_gas_equipment.dart';


class EgxuItem {
  final String dateFrom;
  final String dateTo;
  final String type;
  final String factory1;
  final String factory2;
  final String? imagePath;

  EgxuItem({
    required this.dateFrom,
    required this.dateTo,
    required this.type,
    required this.factory1,
    required this.factory2,
    this.imagePath,
  });
}

class StampModel {
  final String stampNumber;
  final String date;
  final String place;
  final String connectionPoint;
  final String qr;
  final bool isActive;

  StampModel({
    required this.stampNumber,
    required this.date,
    required this.place,
    required this.connectionPoint,
    required this.qr,
    required this.isActive,
  });
}

class GazItem {
  final String name;
  final double hourlyConsumption;

  GazItem({
    required this.name,
    required this.hourlyConsumption,
  });
}

class GazRow {
  GazItem? item;
  int quantity;

  GazRow({
    this.item,
    this.quantity = 1,
  });

  double get total =>
      item == null ? 0 : item!.hourlyConsumption * quantity;
}



class GazUsageResult {
  final GrsGasEquipment equipment;
  final int quantity;
  final double total;

  GazUsageResult({
    required this.equipment,
    required this.quantity,
    required this.total,
  });
}

