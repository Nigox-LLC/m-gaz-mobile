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
      stamp: stamp,
      regionId: 1,
      districtId: 4,
      typeOfActivityId: 2,
      employeeId: 3,
    );

    final item = (request.toJson()['list'] as List).single as Map;
    final real = (item['real_numbers'] as List).single as Map;

    expect(stamp.number, 'T-00451');
    expect(item['egxu_id'], 25);
    expect(item['gas_usage_status'], 'tagged');
    expect(request.toJson()['document_id'], 12);
    expect(real['real_number'], 'T-00451');
    expect(real['from_date'], '2026-01-10');
    expect(stamp.sealLocation, 'Kirish zulfini');
  });
}
