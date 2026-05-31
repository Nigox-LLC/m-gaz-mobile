import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../di.dart';
import '../../../../../data/datasources/eghu_indicator_api.dart';
import '../../../../../data/models/eghu_indicator_document.dart';
import '../bloc/eghu_indicator_list_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/eghu_action_card.dart';
import '../widgets/eghu_action_filter_sheet.dart';
import '../widgets/eghu_action_header.dart';
import '../widgets/eghu_indicator_filter_sheet.dart';
import 'eghu_indicator_create_page.dart';
import 'eghu_indicator_detail_page.dart';

class EghuIndicatorUploadPage extends StatefulWidget {
  const EghuIndicatorUploadPage({
    super.key,
    this.api,
    this.bloc,
    this.consumerApi,
    this.consumerSource,
    this.filterSource,
  });

  final EghuIndicatorApi? api;
  final EghuIndicatorListBloc? bloc;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuActionFilterDataSource? filterSource;

  @override
  State<EghuIndicatorUploadPage> createState() =>
      _EghuIndicatorUploadPageState();
}

class _EghuIndicatorUploadPageState extends State<EghuIndicatorUploadPage> {
  final _searchController = TextEditingController();
  EghuIndicatorApi? _api;
  EghuIndicatorListBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? di.get<EghuIndicatorApi>();
    _bloc = widget.bloc ?? EghuIndicatorListBloc(api: _api!, limit: 10)
      ..add(const EghuIndicatorListStarted());
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc!,
      child: Scaffold(
        backgroundColor: EghuActionCreateColors.white,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    BlocBuilder<EghuIndicatorListBloc, EghuIndicatorListState>(
                      buildWhen: (previous, current) =>
                          previous.hasActiveFilters != current.hasActiveFilters,
                      builder: (context, state) => EghuActionHeader(
                        title: Words.actionEghuIndicatorUpload.tr(),
                        onAdd: _openCreatePage,
                        searchController: _searchController,
                        onSearchChanged: (value) =>
                            _bloc?.add(EghuIndicatorSearchChanged(value)),
                        onFilter: () => _openFilterSheet(context, state.filter),
                        filterActive: state.hasActiveFilters,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _IndicatorListBody(
                        api: _api!,
                        consumerApi: widget.consumerApi,
                        consumerSource: widget.consumerSource,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreatePage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EghuIndicatorCreatePage(
          api: _api,
          consumerApi: widget.consumerApi,
          consumerSource: widget.consumerSource,
        ),
      ),
    );
    if (!mounted || created != true) return;
    _bloc?.add(const EghuIndicatorListRefreshed());
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    EghuIndicatorListFilter initialFilter,
  ) async {
    final result = await showModalBottomSheet<EghuIndicatorListFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuIndicatorFilterBottomSheet(
        initialFilter: initialFilter,
        source: widget.filterSource,
      ),
    );

    if (!mounted || result == null) return;
    _bloc?.add(EghuIndicatorFilterChanged(result));
  }
}

class _IndicatorListBody extends StatelessWidget {
  const _IndicatorListBody({
    required this.api,
    required this.consumerApi,
    required this.consumerSource,
  });

  final EghuIndicatorApi api;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EghuIndicatorListBloc, EghuIndicatorListState>(
      builder: (context, state) {
        if (state.isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == EghuIndicatorListStatus.failure &&
            state.documents.isEmpty) {
          return _ListMessage(
            message: state.errorMessage,
            actionLabel: Words.retry.tr(),
            onAction: () => context.read<EghuIndicatorListBloc>().add(
              const EghuIndicatorListStarted(),
            ),
          );
        }

        final documents = state.documents;
        if (documents.isEmpty) {
          return _ListMessage(message: Words.noInformationFound.tr());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<EghuIndicatorListBloc>().add(
              const EghuIndicatorListRefreshed(),
            );
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 260) {
                context.read<EghuIndicatorListBloc>().add(
                  const EghuIndicatorListLoadMoreRequested(),
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
                return EghuActionCard(
                  data: _cardData(document),
                  onTap: () => _openDetail(context, document),
                );
              },
            ),
          ),
        );
      },
    );
  }

  EghuActionCardData _cardData(EghuIndicatorDocument document) {
    final formattedDate = DateFormat(
      'dd.MM.yyyy HH:mm:ss',
    ).format(document.createdAt.toLocal());
    return EghuActionCardData(
      personalAccount: document.personalAccount.isEmpty
          ? '${document.consumerId}'
          : document.personalAccount,
      factoryNumber: document.factoryNumber.isEmpty
          ? document.egxuType
          : document.factoryNumber,
      region: document.region,
      district: document.district,
      date: formattedDate,
      employee: document.consumerName.isNotEmpty
          ? document.consumerName
          : document.employee,
      factoryNumberLabel: document.factoryNumber.isEmpty
          ? '${Words.eghuType.tr()}:'
          : null,
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    EghuIndicatorDocument document,
  ) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EghuIndicatorDetailPage(
          id: document.id,
          api: api,
          consumerApi: consumerApi,
          consumerSource: consumerSource,
        ),
      ),
    );
    if (!context.mounted || updated != true) return;
    context.read<EghuIndicatorListBloc>().add(
      const EghuIndicatorListRefreshed(),
    );
  }
}

class _ListMessage extends StatelessWidget {
  const _ListMessage({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
