import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_indicator_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_indicator_document.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_indicator_list_bloc.dart';

void main() {
  group('EghuIndicatorListBloc', () {
    test('loads first page', () async {
      final api = _FakeIndicatorListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuIndicatorListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(const EghuIndicatorListStarted());
      await pumpEventQueue();

      expect(api.requestedLimit, 10);
      expect(api.requestedOffset, 0);
      expect(bloc.state.status, EghuIndicatorListStatus.success);
      expect(bloc.state.documents.single.id, 1);
    });

    test('reloads first page with server search query', () async {
      final api = _FakeIndicatorListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuIndicatorListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(const EghuIndicatorSearchChanged('1430200078'));
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await pumpEventQueue();

      expect(bloc.state.searchQuery, '1430200078');
      expect(api.search, '1430200078');
      expect(api.requestedOffset, 0);
    });

    test('reloads first page with selected filters', () async {
      final api = _FakeIndicatorListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuIndicatorListBloc(api: api);
      addTearDown(bloc.close);
      final filter = EghuIndicatorListFilter(
        startDate: DateTime(2026, 5),
        endDate: DateTime(2026, 5, 31),
        regionId: 7,
        regionName: 'Samarqand',
        districtId: 88,
        districtName: 'Samarqand shahar',
      );

      bloc.add(EghuIndicatorFilterChanged(filter));
      await pumpEventQueue();

      expect(bloc.state.filter, filter);
      expect(bloc.state.hasActiveFilters, isTrue);
      expect(api.startDate, DateTime(2026, 5));
      expect(api.endDate, DateTime(2026, 5, 31));
      expect(api.regionId, 7);
      expect(api.districtId, 88);
    });

    test('clears filters when empty filter is applied', () async {
      final api = _FakeIndicatorListApi();
      final bloc = EghuIndicatorListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(
        EghuIndicatorFilterChanged(
          EghuIndicatorListFilter(regionId: 7, districtId: 88),
        ),
      );
      await pumpEventQueue();
      bloc.add(const EghuIndicatorFilterChanged(EghuIndicatorListFilter()));
      await pumpEventQueue();

      expect(bloc.state.hasActiveFilters, isFalse);
      expect(api.regionId, isNull);
      expect(api.districtId, isNull);
    });

    test('loads next page when next URL exists', () async {
      final api = _FakeIndicatorListApi(
        first: PaginatedResponse(
          count: 2,
          next:
              'https://backend.m-gaz.uz/api/egxu-indicators/indicators/?limit=10&offset=10&search=1430200078',
          previous: null,
          results: [_document(id: 1)],
        ),
        next: PaginatedResponse(
          count: 2,
          next: null,
          previous: null,
          results: [_document(id: 2)],
        ),
      );
      final bloc = EghuIndicatorListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(const EghuIndicatorListStarted());
      await pumpEventQueue();
      bloc.add(const EghuIndicatorListLoadMoreRequested());
      await pumpEventQueue();

      expect(api.nextUrl, contains('search=1430200078'));
      expect(bloc.state.documents.map((item) => item.id), [1, 2]);
      expect(bloc.state.hasNextPage, isFalse);
    });
  });
}

class _FakeIndicatorListApi implements EghuIndicatorListApi {
  _FakeIndicatorListApi({this.first, this.next});

  final PaginatedResponse<EghuIndicatorDocument>? first;
  final PaginatedResponse<EghuIndicatorDocument>? next;
  int? requestedLimit;
  int? requestedOffset;
  String? search;
  DateTime? startDate;
  DateTime? endDate;
  int? regionId;
  int? districtId;
  String? nextUrl;

  @override
  Future<PaginatedResponse<EghuIndicatorDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    int? regionId,
    int? districtId,
  }) async {
    requestedLimit = limit;
    requestedOffset = offset;
    this.search = search;
    this.startDate = startDate;
    this.endDate = endDate;
    this.regionId = regionId;
    this.districtId = districtId;
    return first ??
        const PaginatedResponse(
          count: 0,
          next: null,
          previous: null,
          results: [],
        );
  }

  @override
  Future<PaginatedResponse<EghuIndicatorDocument>> getNextPage(
    String url,
  ) async {
    nextUrl = url;
    return next ??
        const PaginatedResponse(
          count: 0,
          next: null,
          previous: null,
          results: [],
        );
  }
}

EghuIndicatorDocument _document({required int id}) {
  return EghuIndicatorDocument(
    id: id,
    createdAt: DateTime(2026, 5, 31, 18),
    updatedAt: null,
    isActive: true,
    value: '50.00',
    consumerId: 68424,
    egxuId: 1436318,
    personalAccount: '1430200078',
    consumerName: '"ZO`R SHASHLIK" OILAVIY KORXONA',
    factoryNumber: '11140',
    egxuType: 'СТГ 80/400',
    region: '"Hududgaz Samarqand" GTF',
    district: 'Samarqand shahar',
    employee: '',
  );
}
