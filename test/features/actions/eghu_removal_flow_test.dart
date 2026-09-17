import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/features/actions/data/models/eghu_removal_flow.dart';

void main() {
  test('parses target info and builds documented stamp removal payload', () {
    final info = EghuTargetInfo.fromJson({
      'egxu_list': [
        {
          'egxu_id': 25,
          'egxu_type_name': 'STG-80',
          'one_factory': '1002345',
          'reals': [
            {
              'id': 101,
              'real_number': 'T-00451',
              'seal_status': 'Soz',
              'installed_date': '2026-01-10',
              'seal_location': 'Kirish zulfini',
            },
          ],
        },
      ],
    });

    final stamp = info.egxus.single.reals.single;
    final request = EghuStampRemovalRequest(
      datetime: DateTime(2026, 9, 15, 12),
      documentId: 12,
      egxuId: info.egxus.single.id!,
      regionId: 1,
      districtId: 4,
      typeOfActivityId: 2,
      employeeId: 3,
      realNumbers: [stamp],
    );

    final payload = request.toJson();
    final item = (payload['list'] as List).single as Map;
    final real = (payload['real_numbers'] as List).single as Map;

    expect(stamp.number, 'T-00451');
    expect(item['egxu_id'], 25);
    expect(item['gas_usage_status'], 'tagged');
    expect(payload['document_id'], 12);
    expect(real['real_number'], 'T-00451');
    expect(real['from_date'], '2026-01-10');
    expect(stamp.sealLocation, 'Kirish zulfini');
    expect(item.containsKey('real_numbers'), isFalse);
    expect(item.containsKey('gas_equipments'), isFalse);
  });

  test('does not add gas equipment data to the removal payload', () {
    final payload = EghuStampRemovalRequest(
      datetime: DateTime(2026, 9, 15, 12),
      documentId: 12,
      egxuId: 25,
      gasUsageStatus: 'used',
    ).toJson();

    final item = (payload['list'] as List).single as Map;
    expect(item.containsKey('gas_equipments'), isFalse);
    expect(payload.containsKey('real_numbers'), isFalse);
  });

  test('EGHU targets remain available when their seals are inactive', () {
    final info = EghuTargetInfo.fromJson({
      'egxu_list': [
        {'egxu_id': 1, 'is_removed': true},
        {'egxu_id': 2, 'is_active': false},
        {'egxu_id': 3, 'is_removed': false},
      ],
      'has_removed_egxu': true,
      'can_reinstall': true,
    });

    expect(info.egxus[0].isRemoved, isTrue);
    expect(info.egxus[1].isActive, isFalse);
    expect(info.hasRemovedEgxu, isTrue);
    expect(info.canReinstall, isTrue);
    expect(info.egxus[0].canBeRemoved, isTrue);
    expect(info.egxus[1].canBeRemoved, isTrue);
    expect(info.egxus[2].canBeRemoved, isTrue);
  });

  test('parses nested EGHU target data without requiring active seals', () {
    final info = EghuTargetInfo.fromJson({
      'egxu_list': [
        {
          'id': 99,
          'egxu': {
            'id': 25,
            'egxu_type': {'name': 'SMART'},
            'one_factory': 'GM25000000005995',
            'is_removed': false,
            'is_active': false,
            'reals': [
              {'real_number': 'R-1', 'remove_seal': true},
            ],
          },
        },
      ],
    });

    expect(info.egxus.single.id, 25);
    expect(info.egxus.single.reals.single.removeSeal, isTrue);
    expect(info.egxus.single.canBeRemoved, isTrue);
  });
}
