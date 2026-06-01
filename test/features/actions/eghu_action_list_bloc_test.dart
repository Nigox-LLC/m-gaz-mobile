import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_working_document.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_action_list_bloc/eghu_action_list_bloc.dart';

void main() {
  group('EghuActionListBloc', () {
    test('loads first page from EGXU removals list API contract', () async {
      final api = _FakeListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuActionListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(const EghuActionListStarted());
      await pumpEventQueue();

      expect(api.requestedLimit, 10);
      expect(api.requestedOffset, 0);
      expect(bloc.state.status, EghuActionListStatus.success);
      expect(bloc.state.documents.single.id, 1);
    });

    test('passes action type filter to list API', () async {
      final api = _FakeListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuActionListBloc(
        api: api,
        actionType: ActionMenuType.reinstall,
      );
      addTearDown(bloc.close);

      bloc.add(const EghuActionListStarted());
      await pumpEventQueue();

      expect(api.actionType, ActionMenuType.reinstall);
    });

    test('reloads first page with server search query', () async {
      final api = _FakeListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuActionListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(const EghuActionListSearchChanged('1430200078'));
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await pumpEventQueue();

      expect(bloc.state.searchQuery, '1430200078');
      expect(api.search, '1430200078');
      expect(api.requestedOffset, 0);
    });

    test('reloads first page with selected filters', () async {
      final api = _FakeListApi(
        first: PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [_document(id: 1)],
        ),
      );
      final bloc = EghuActionListBloc(
        api: api,
        actionType: ActionMenuType.detach,
      );
      addTearDown(bloc.close);
      final filter = EghuActionListFilter(
        dateFrom: DateTime(2026, 5),
        dateTo: DateTime(2026, 5, 31),
        regionId: 7,
        regionName: 'Samarqand',
        districtId: 88,
        districtName: 'Samarqand shahar',
        reason: EghuActionReasonFilter.repair,
      );

      bloc.add(EghuActionListFilterChanged(filter));
      await pumpEventQueue();

      expect(bloc.state.filter, filter);
      expect(bloc.state.hasActiveFilters, isTrue);
      expect(api.actionType, ActionMenuType.detach);
      expect(api.createdAtFrom, DateTime(2026, 5));
      expect(api.createdAtTo, DateTime(2026, 5, 31));
      expect(api.regionId, 7);
      expect(api.districtId, 88);
      expect(api.reason, 'repair');
    });

    test('loads next page when next URL exists', () async {
      final api = _FakeListApi(
        first: PaginatedResponse(
          count: 2,
          next:
              'https://backend.m-gaz.uz/api/working-with-egxu/?limit=10&offset=10',
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
      final bloc = EghuActionListBloc(api: api);
      addTearDown(bloc.close);

      bloc.add(const EghuActionListStarted());
      await pumpEventQueue();
      bloc.add(const EghuActionListLoadMoreRequested());
      await pumpEventQueue();

      expect(api.nextUrl, contains('offset=10'));
      expect(bloc.state.documents.map((item) => item.id), [1, 2]);
      expect(bloc.state.hasNextPage, isFalse);
    });

    test('emits failure when list API fails', () async {
      final bloc = EghuActionListBloc(
        api: _FakeListApi(error: Exception('Network error')),
      );
      addTearDown(bloc.close);

      bloc.add(const EghuActionListStarted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuActionListStatus.failure);
      expect(bloc.state.errorMessage, 'Network error');
    });
  });
}

class _FakeListApi implements EghuActionListApi {
  _FakeListApi({this.first, this.next, this.error});

  final PaginatedResponse<EghuWorkingDocument>? first;
  final PaginatedResponse<EghuWorkingDocument>? next;
  final Object? error;
  int? requestedLimit;
  int? requestedOffset;
  ActionMenuType? actionType;
  String? search;
  DateTime? createdAtFrom;
  DateTime? createdAtTo;
  int? regionId;
  int? districtId;
  String? reason;
  String? nextUrl;

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    ActionMenuType? actionType,
    String? search,
    DateTime? createdAtFrom,
    DateTime? createdAtTo,
    int? regionId,
    int? districtId,
    String? reason,
  }) async {
    requestedLimit = limit;
    requestedOffset = offset;
    this.actionType = actionType;
    this.search = search;
    this.createdAtFrom = createdAtFrom;
    this.createdAtTo = createdAtTo;
    this.regionId = regionId;
    this.districtId = districtId;
    this.reason = reason;
    final error = this.error;
    if (error != null) throw error;
    return first ??
        const PaginatedResponse(
          count: 0,
          next: null,
          previous: null,
          results: [],
        );
  }

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getNextPage(String url) async {
    nextUrl = url;
    final error = this.error;
    if (error != null) throw error;
    return next ??
        const PaginatedResponse(
          count: 0,
          next: null,
          previous: null,
          results: [],
        );
  }
}

EghuWorkingDocument _document({required int id}) {
  return EghuWorkingDocument(
    id: id,
    datetime: DateTime(2026, 5, 28, 10),
    region: 'Andijon',
    district: 'Andijon tumani',
    typeOfActivity: 'Sanoat',
    documentType: 'consumer',
    documentTypeDisplay: "Iste'molchi",
    employee: 'Tester',
    isActive: true,
  );
}
