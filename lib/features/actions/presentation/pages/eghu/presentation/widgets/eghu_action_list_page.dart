import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../../../di.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_removal_detail.dart';
import '../../../../../data/models/eghu_working_document.dart';
import '../../../../../domain/entities/action_menu_item.dart';
import '../bloc/eghu_action_list_bloc.dart';
import '../pages/eghu_action_create_page.dart';
import '../pages/eghu_detach_create_page.dart';
import 'eghu_action_card.dart';
import 'eghu_action_filter_sheet.dart';
import 'eghu_action_header.dart';

class EghuActionListPage extends StatefulWidget {
  const EghuActionListPage({
    super.key,
    required this.title,
    this.items = const [],
    this.onAdd,
    this.useRemoteList = false,
    this.actionType,
    this.api,
    this.filterSource,
    this.bloc,
  });

  final String title;
  final List<EghuActionCardData> items;
  final FutureOr<bool?> Function()? onAdd;
  final bool useRemoteList;
  final ActionMenuType? actionType;
  final EghuActionApi? api;
  final EghuActionFilterDataSource? filterSource;
  final EghuActionListBloc? bloc;

  @override
  State<EghuActionListPage> createState() => _EghuActionListPageState();
}

class _EghuActionListPageState extends State<EghuActionListPage> {
  final _searchController = TextEditingController();
  EghuActionListBloc? _bloc;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.useRemoteList) {
      _bloc =
          widget.bloc ??
          EghuActionListBloc(
            api: widget.api ?? di.get<EghuActionApi>(),
            actionType: widget.actionType,
          );
      _bloc!.add(const EghuActionListStarted());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useRemoteList) {
      return BlocProvider.value(value: _bloc!, child: _buildScaffold());
    }

    return _buildScaffold();
  }

  Widget _buildScaffold() {
    final content = widget.useRemoteList
        ? _RemoteActionList(api: widget.api)
        : _StaticActionList(items: widget.items, searchQuery: _searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  Expanded(child: content),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddPressed() async {
    final created = await widget.onAdd?.call();
    if (!mounted || created != true || !widget.useRemoteList) return;

    _bloc?.add(const EghuActionListRefreshed());
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  Widget _buildHeader() {
    if (!widget.useRemoteList) {
      return EghuActionHeader(
        title: widget.title,
        onAdd: widget.onAdd == null ? null : _handleAddPressed,
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
      );
    }

    return BlocBuilder<EghuActionListBloc, EghuActionListState>(
      builder: (context, state) {
        return EghuActionHeader(
          title: widget.title,
          onAdd: widget.onAdd == null ? null : _handleAddPressed,
          searchController: _searchController,
          onSearchChanged: _onRemoteSearchChanged,
          onFilter: () => _openFilterSheet(context, state.filter),
          filterActive: state.hasActiveFilters,
        );
      },
    );
  }

  void _onRemoteSearchChanged(String value) {
    _bloc?.add(EghuActionListSearchChanged(value));
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    EghuActionListFilter filter,
  ) async {
    final result = await showModalBottomSheet<EghuActionListFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuActionFilterBottomSheet(
        initialFilter: filter,
        source: widget.filterSource,
      ),
    );

    if (result == null || !mounted) return;
    _bloc?.add(EghuActionListFilterChanged(result));
  }
}

class _StaticActionList extends StatelessWidget {
  const _StaticActionList({required this.items, required this.searchQuery});

  final List<EghuActionCardData> items;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where((item) => _matchesCardData(item, searchQuery))
        .toList();

    if (visibleItems.isEmpty) return const _EghuListEmpty();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        return EghuActionCard(data: visibleItems[index]);
      },
    );
  }
}

class _RemoteActionList extends StatelessWidget {
  const _RemoteActionList({this.api});

  final EghuActionApi? api;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EghuActionListBloc, EghuActionListState>(
      builder: (context, state) {
        if (state.isInitialLoading) return const _EghuListShimmer();

        if (state.status == EghuActionListStatus.failure &&
            state.documents.isEmpty) {
          return _EghuListError(
            message: state.errorMessage,
            onRetry: () => context.read<EghuActionListBloc>().add(
              const EghuActionListStarted(),
            ),
          );
        }

        final documents = state.documents;

        if (documents.isEmpty) return const _EghuListEmpty();

        return RefreshIndicator(
          onRefresh: () async {
            context.read<EghuActionListBloc>().add(
              const EghuActionListRefreshed(),
            );
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 260) {
                context.read<EghuActionListBloc>().add(
                  const EghuActionListLoadMoreRequested(),
                );
              }
              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: documents.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= documents.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final document = documents[index];
                final listBloc = context.read<EghuActionListBloc>();
                return EghuActionCard(
                  data: _cardDataFromDocument(document),
                  onTap: () => _openDetail(context, listBloc, document),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    EghuActionListBloc listBloc,
    EghuWorkingDocument document,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final detailApi = api ?? di.get<EghuActionApi>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    EghuRemovalDetail detail;
    try {
      detail = await detailApi.getDetail(document.id);
    } catch (e) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      return;
    }

    navigator.pop();

    final isReinstall =
        document.documentType == 'reinstall' ||
        detail.documentType == 'reinstall';
    final saved = await navigator.push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => isReinstall
            ? EghuActionCreatePage(
                actionType: ActionMenuType.reinstall,
                detail: detail,
              )
            : EghuDetachCreatePage(detail: detail),
      ),
    );

    if (saved == true) listBloc.add(const EghuActionListRefreshed());
  }
}

EghuActionCardData _cardDataFromDocument(EghuWorkingDocument document) {
  return EghuActionCardData(
    personalAccount: document.personalAccount.isNotEmpty
        ? document.personalAccount
        : '-',
    factoryNumber: (document.factoryNumber1 == null || document.factoryNumber2 == null)
        ? "${document.factoryNumber1}\n${document.factoryNumber2}"
        : '-',
    region: document.region,
    district: document.district,
    date: DateFormat('dd.MM.yyyy HH:mm:ss').format(document.datetime.toLocal()),
    employee: document.employee,
  );
}

bool _matchesCardData(EghuActionCardData data, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  final target =
      '${data.personalAccount} ${data.factoryNumber} ${data.region} '
              '${data.district} ${data.date} ${data.employee}'
          .toLowerCase();
  return target.contains(normalizedQuery);
}

class _EghuListShimmer extends StatelessWidget {
  const _EghuListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFEFEFEF),
          highlightColor: Colors.white,
          child: Container(
            height: 172,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class _EghuListEmpty extends StatelessWidget {
  const _EghuListEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(Words.noInformationFound.tr()));
  }
}

class _EghuListError extends StatelessWidget {
  const _EghuListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(Words.retry.tr())),
        ],
      ),
    );
  }
}
