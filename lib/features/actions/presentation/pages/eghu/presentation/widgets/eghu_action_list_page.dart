import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../di.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_working_document.dart';
import '../bloc/eghu_action_list_bloc.dart';
import 'eghu_action_card.dart';
import 'eghu_action_header.dart';

class EghuActionListPage extends StatefulWidget {
  const EghuActionListPage({
    super.key,
    required this.title,
    this.items = const [],
    this.onAdd,
    this.useRemoteList = false,
    this.api,
    this.bloc,
  });

  final String title;
  final List<EghuActionCardData> items;
  final VoidCallback? onAdd;
  final bool useRemoteList;
  final EghuActionApi? api;
  final EghuActionListBloc? bloc;

  @override
  State<EghuActionListPage> createState() => _EghuActionListPageState();
}

class _EghuActionListPageState extends State<EghuActionListPage> {
  EghuActionListBloc? _bloc;

  @override
  void initState() {
    super.initState();
    if (widget.useRemoteList) {
      _bloc =
          widget.bloc ??
          EghuActionListBloc(api: widget.api ?? di.get<EghuActionApi>());
      _bloc!.add(const EghuActionListStarted());
    }
  }

  @override
  void dispose() {
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.useRemoteList
        ? BlocProvider.value(value: _bloc!, child: const _RemoteActionList())
        : _StaticActionList(items: widget.items);

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
                  EghuActionHeader(title: widget.title, onAdd: widget.onAdd),
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
}

class _StaticActionList extends StatelessWidget {
  const _StaticActionList({required this.items});

  final List<EghuActionCardData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EghuListEmpty();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return EghuActionCard(data: items[index]);
      },
    );
  }
}

class _RemoteActionList extends StatelessWidget {
  const _RemoteActionList();

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

        if (state.documents.isEmpty) return const _EghuListEmpty();

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
              itemCount: state.documents.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.documents.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return EghuActionCard(
                  data: _cardDataFromDocument(state.documents[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

EghuActionCardData _cardDataFromDocument(EghuWorkingDocument document) {
  return EghuActionCardData(
    personalAccount: document.documentTypeDisplay.isNotEmpty
        ? document.documentTypeDisplay
        : document.documentType,
    factoryNumber: document.typeOfActivity,
    region: document.region,
    district: document.district,
    date: DateFormat('dd.MM.yyyy HH:mm').format(document.datetime.toLocal()),
    employee: document.employee,
    personalAccountLabel: 'Hujjat turi:',
    factoryNumberLabel: 'Faoliyat turi:',
  );
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
    return const Center(child: Text("Ma'lumot topilmadi"));
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
          TextButton(onPressed: onRetry, child: const Text('Qayta urinish')),
        ],
      ),
    );
  }
}
