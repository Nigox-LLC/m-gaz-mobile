import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_working_document.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_action_list_bloc.dart';

void main() {
  group('EghuActionListBloc', () {
    test('loads first page from working-with-egxu list API contract', () async {
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
  String? nextUrl;

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
  }) async {
    requestedLimit = limit;
    requestedOffset = offset;
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
