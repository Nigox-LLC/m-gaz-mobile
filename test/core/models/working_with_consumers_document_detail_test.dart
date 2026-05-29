import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';

void main() {
  test(
    'parses EGHU detail object response with lookup objects and string files',
    () {
      final detail = WorkingWithConsumersDetailModel.fromJson({
        'id': 1,
        'egxu_list': [
          {
            'id': 44,
            'consumer_relation_egxu': {
              'id': 10,
              'type_of_activity': {'id': 110, 'name': 'Sanoat'},
              'gas_networks': {'id': 20, 'name': 'Tarmoq'},
              'egxu_connection_point': {'id': 30, 'name': 'Nuqta'},
              'month_start_reading': 1,
              'additional_gas': 2,
              'violation_gas': 3,
              'additional_balance': 4,
              'month_end_reading': 5,
              'reading_difference': 6,
              'total_gas': 7,
              'grp_exists': true,
              'grp_loss': 8,
              'ghu_id_number': 9,
              'mov_grp_after_egxu': 'BEFORE_EGHU',
              'gaz': 'SEASONAL',
              'counter_status': 'Activity',
              'work_activity': true,
              'is_active': true,
            },
            'company_info': {
              'id': 11,
              'direction': {'id': 1, 'name': 'Direction'},
              'ministry': {'id': 2, 'name': 'Ministry'},
              'grs': {'id': 3, 'name': 'GRS'},
              'egxu_industrial_collector': {'id': 4, 'name': 'Collector'},
              'grs_measurement_devices': {'id': 5, 'name': 'Device'},
              'grp_types': {'id': 6, 'name': 'GRP'},
              'neighborhood': {'id': 7, 'name': 'Mahalla'},
              'direction_id': 1,
              'ministry_id': 2,
              'grs_id': 3,
              'egxu_industrial_collector_id': 4,
              'grs_measurement_devices_id': 5,
              'grp_types_id': 6,
              'neighborhood_id': 7,
              'account_number': '100',
              'contract_number': 'CN-1',
              'company_director': 'Director',
              'company_tin': '123',
              'phone': '+998',
              'email': 'user@example.com',
              'address': 'Address',
              'type_consumers': 'AGTKSH',
              'season': 'SPRING',
              'is_active': true,
            },
            'gas_equipment_list': [
              {
                'id': 55,
                'gas_equipment': {
                  'id': 66,
                  'name': 'Qozon',
                  'hourly_gas_consumption': 1.5,
                },
                'hourly_gas_consumption': 3,
                'quantity': 2,
              },
            ],
            'real': 'string',
            'hourly_list_indicator': 'string',
            'indicator_images': 'string',
            'hourly_files': 'string',
            'certificates': 'string',
            'egxu_type': {
              'id': 77,
              'name': 'Type',
              'photo': 'photo',
              'code': 'code',
            },
            'one_factory': 'Factory 1',
            'two_factory': 'Factory 2',
            'from_date': '2026-05-28',
            'to_date': '2026-05-28',
            'is_active': true,
          },
        ],
      });

      final item = detail.egxuList!.single;
      final relation = item.consumerRelationEgxu!;
      final company = item.companyInfo!;
      final equipment = item.gasEquipmentList!.single;

      expect(relation.typeOfActivityId, 110);
      expect(relation.typeOfActivity, 'Sanoat');
      expect(relation.gasNetworksId, 20);
      expect(relation.gasNetworks, 'Tarmoq');
      expect(relation.egxuConnectionPointId, 30);
      expect(relation.egxuConnectionPoint, 'Nuqta');
      expect(company.direction?.name, 'Direction');
      expect(company.grsMeasurementDevicesId, 5);
      expect(equipment.hourlyGasConsumption, 3);
      expect(item.real, isNull);
      expect(item.realRaw, 'string');
      expect(item.indicatorImages, isNull);
      expect(item.indicatorImagesRaw, 'string');
    },
  );
}
