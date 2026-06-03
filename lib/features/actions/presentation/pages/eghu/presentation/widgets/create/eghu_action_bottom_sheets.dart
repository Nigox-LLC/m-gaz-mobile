import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../core/api/global/global_api.dart';
import '../../../../../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../../../../../core/common/words.dart';
import '../../../../../../../../core/models/global/global_model.dart';
import '../../../../../../../../core/models/paginated_response/paginated_response.dart';
import '../../../../../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../../../../di.dart';
import 'eghu_action_form_fields.dart';

enum EghuAttachmentSource { camera, device }

abstract class EghuActionConsumerSource {
  Future<PaginatedResponse<WorkingWithConsumersList>> getDocuments({
    int limit = 20,
    String? search,
  });

  Future<PaginatedResponse<WorkingWithConsumersList>> getNextPage(String url);

  Future<WorkingWithConsumersDetailModel> getDocumentById(int id);
}

class ConsumerRelationsEghuSource implements EghuActionConsumerSource {
  const ConsumerRelationsEghuSource(this._api);

  final ConsumerRelationsApi _api;

  @override
  Future<PaginatedResponse<WorkingWithConsumersList>> getDocuments({
    int limit = 20,
    String? search,
  }) {
    return _api.getDocuments(limit: limit, search: search);
  }

  @override
  Future<PaginatedResponse<WorkingWithConsumersList>> getNextPage(String url) {
    return _api.getNextPage(url);
  }

  @override
  Future<WorkingWithConsumersDetailModel> getDocumentById(int id) {
    return _api.getDocumentById(id);
  }
}

String eghuTitle(ConsumersEgxuItem item) {
  final type = item.egxuType?.name;
  final factories = [
    item.oneFactory,
    item.twoFactory,
  ].where((value) => value?.trim().isNotEmpty == true).join(', ');
  if (factories.isNotEmpty) return factories;
  if (type?.trim().isNotEmpty == true) return type!;
  return 'EGHU #${item.id ?? '-'}';
}

class EghuDeviceSelection {
  const EghuDeviceSelection({required this.detail, required this.item});

  final WorkingWithConsumersDetailModel detail;
  final ConsumersEgxuItem item;
}

/// Consumer + EGHU pre-selection forwarded from the consumer detail screen so
/// the create form opens with both already chosen.
class EghuActionPreselection {
  const EghuActionPreselection({
    required this.consumer,
    required this.eghu,
    required this.detail,
  });

  final WorkingWithConsumersList consumer;
  final ConsumersEgxuItem eghu;
  final WorkingWithConsumersDetailModel detail;
}

/// Source for the stamp installation place directory
/// (`entity_type=Tamgaornatishjoyi`).
abstract class EghuStampPlaceSource {
  Future<PaginatedResponse<GlobalModel>> getPlaces({
    int limit = 20,
    int offset = 0,
    String? search,
  });

  Future<PaginatedResponse<GlobalModel>> getNextPage(String url);
}

class GlobalApiStampPlaceSource implements EghuStampPlaceSource {
  const GlobalApiStampPlaceSource(this._api);

  final GlobalApi _api;

  @override
  Future<PaginatedResponse<GlobalModel>> getPlaces({
    int limit = 20,
    int offset = 0,
    String? search,
  }) {
    return _api.getStampInstallationPlaces(
      limit: limit,
      offset: offset,
      search: search,
    );
  }

  @override
  Future<PaginatedResponse<GlobalModel>> getNextPage(String url) {
    return _api.getStampInstallationPlacesNextPage(url);
  }
}

EghuStampPlaceSource defaultStampPlaceSource() =>
    GlobalApiStampPlaceSource(di.get<GlobalApi>());

class EghuConsumerPickerSheet extends StatefulWidget {
  const EghuConsumerPickerSheet({
    super.key,
    required this.source,
    this.selected,
  });

  final EghuActionConsumerSource source;
  final WorkingWithConsumersList? selected;

  @override
  State<EghuConsumerPickerSheet> createState() =>
      _EghuConsumerPickerSheetState();
}

class _EghuConsumerPickerSheetState extends State<EghuConsumerPickerSheet> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _items = <WorkingWithConsumersList>[];
  Timer? _debounce;
  String? _nextUrl;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PickerFrame(
      child: Column(
        children: [
          _SearchField(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const _PickerShimmer();
    if (_error != null) return _PickerError(message: _error!, onRetry: _retry);
    if (_items.isEmpty) {
      return _PickerEmpty(message: Words.noInformationFound.tr());
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _items.length) return const _LoadingMoreTile();
        final item = _items[index];
        final selected = widget.selected?.id == item.id;
        return _ConsumerTile(
          item: item,
          selected: selected,
          onTap: () => Navigator.of(context).pop(item),
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetch(reset: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 260) {
      _fetchMore();
    }
  }

  Future<void> _fetch({required bool reset}) async {
    setState(() {
      _loading = reset;
      _error = null;
      if (reset) {
        _items.clear();
        _nextUrl = null;
      }
    });

    try {
      final response = await widget.source.getDocuments(
        limit: 20,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(response.results);
        _nextUrl = response.next;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _fetchMore() async {
    if (_loadingMore || _nextUrl == null) return;
    setState(() => _loadingMore = true);

    try {
      final response = await widget.source.getNextPage(_nextUrl!);
      if (!mounted) return;
      setState(() {
        _items.addAll(response.results);
        _nextUrl = response.next;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _retry() => _fetch(reset: true);
}

class EghuDevicePickerSheet extends StatefulWidget {
  const EghuDevicePickerSheet({
    super.key,
    required this.source,
    required this.consumer,
    this.selected,
  });

  final EghuActionConsumerSource source;
  final WorkingWithConsumersList consumer;
  final ConsumersEgxuItem? selected;

  @override
  State<EghuDevicePickerSheet> createState() => _EghuDevicePickerSheetState();
}

class _EghuDevicePickerSheetState extends State<EghuDevicePickerSheet> {
  final _searchController = TextEditingController();
  List<ConsumersEgxuItem> _items = const [];
  WorkingWithConsumersDetailModel? _detail;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PickerFrame(
      child: Column(
        children: [
          _SearchField(controller: _searchController),
          const SizedBox(height: 12),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const _PickerShimmer();
    if (_error != null) return _PickerError(message: _error!, onRetry: _fetch);

    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _items
        : _items.where((item) {
            final target =
                '${item.id ?? ''} ${eghuTitle(item)} ${item.egxuType?.name ?? ''}'
                    .toLowerCase();
            return target.contains(query);
          }).toList();

    if (filtered.isEmpty) return _PickerEmpty(message: Words.eghuNotFound.tr());

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _EghuTile(
          item: item,
          selected: widget.selected?.id == item.id,
          onTap: () {
            final detail = _detail;
            if (detail == null) return;
            Navigator.of(
              context,
            ).pop(EghuDeviceSelection(detail: detail, item: item));
          },
        );
      },
    );
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = await widget.source.getDocumentById(widget.consumer.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _items = detail.egxuList ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
}

class EghuStampPlacePickerSheet extends StatefulWidget {
  const EghuStampPlacePickerSheet({
    super.key,
    required this.source,
    this.selectedId,
  });

  final EghuStampPlaceSource source;
  final int? selectedId;

  @override
  State<EghuStampPlacePickerSheet> createState() =>
      _EghuStampPlacePickerSheetState();
}

class _EghuStampPlacePickerSheetState extends State<EghuStampPlacePickerSheet> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _items = <GlobalModel>[];
  Timer? _debounce;
  String? _nextUrl;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PickerFrame(
      child: Column(
        children: [
          _SearchField(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const _PickerShimmer();
    if (_error != null) return _PickerError(message: _error!, onRetry: _fetch);
    if (_items.isEmpty) {
      return _PickerEmpty(message: Words.noInformationFound.tr());
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _items.length) return const _LoadingMoreTile();
        final item = _items[index];
        return _PickerTile(
          selected: widget.selectedId != null && widget.selectedId == item.id,
          onTap: () => Navigator.of(context).pop(item),
          children: [
            _RichTileLine(
              label: '${Words.stampInstallationPlace.tr()}:',
              value: item.name ?? '-',
            ),
          ],
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetch();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 260) {
      _fetchMore();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
      _items.clear();
      _nextUrl = null;
    });

    try {
      final response = await widget.source.getPlaces(
        limit: 20,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(response.results);
        _nextUrl = response.next;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _fetchMore() async {
    if (_loadingMore || _nextUrl == null) return;
    setState(() => _loadingMore = true);

    try {
      final response = await widget.source.getNextPage(_nextUrl!);
      if (!mounted) return;
      setState(() {
        _items.addAll(response.results);
        _nextUrl = response.next;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }
}

class EghuAttachmentSourceSheet extends StatelessWidget {
  const EghuAttachmentSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 390),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          decoration: const BoxDecoration(
            color: EghuActionCreateColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 13),
              _SourceTile(
                icon: Icons.camera_alt_outlined,
                label: Words.openCamera.tr(),
                onTap: () =>
                    Navigator.of(context).pop(EghuAttachmentSource.camera),
              ),
              const SizedBox(height: 8),
              _SourceTile(
                icon: Icons.create_new_folder_outlined,
                label: Words.uploadFromPhone.tr(),
                onTap: () =>
                    Navigator.of(context).pop(EghuAttachmentSource.device),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerFrame extends StatelessWidget {
  const _PickerFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 390,
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            36,
            20,
            MediaQuery.paddingOf(context).bottom + 8,
          ),
          decoration: const BoxDecoration(
            color: EghuActionCreateColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [child, const _SheetHandle()],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -28,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 39,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE1E1E1),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        key: const Key('eghu-picker-search-field'),
        controller: controller,
        onChanged: onChanged,
        style: eghuText(fontSize: 13, lineHeight: 20),
        decoration: InputDecoration(
          hintText: Words.search.tr().replaceAll('...', ''),
          hintStyle: eghuText(
            fontSize: 13,
            lineHeight: 20,
            color: EghuActionCreateColors.textSub,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: EghuActionCreateColors.textSub,
          ),
          filled: true,
          fillColor: EghuActionCreateColors.field,
          contentPadding: EdgeInsets.zero,
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(EghuActionCreateColors.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _border([Color color = EghuActionCreateColors.stroke]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }
}

class _ConsumerTile extends StatelessWidget {
  const _ConsumerTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final WorkingWithConsumersList item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PickerTile(
      selected: selected,
      onTap: onTap,
      children: [
        _RichTileLine(
          label: '${Words.accountNumber.tr()}:',
          value: item.facial,
        ),
        const SizedBox(height: 2),
        _RichTileLine(label: '${Words.consumer.tr()}:', value: item.consumers),
      ],
    );
  }
}

class _EghuTile extends StatelessWidget {
  const _EghuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ConsumersEgxuItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PickerTile(
      selected: selected,
      onTap: onTap,
      children: [
        _RichTileLine(label: 'EGHU ID:', value: '${item.id ?? '-'}'),
        const SizedBox(height: 2),
        _RichTileLine(label: '${Words.eghu.tr()}:', value: eghuTitle(item)),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.children,
    required this.selected,
    required this.onTap,
  });

  final List<Widget> children;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EghuActionCreateColors.field,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? EghuActionCreateColors.primary
                  : EghuActionCreateColors.stroke,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _RichTileLine extends StatelessWidget {
  const _RichTileLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: eghuText(
          fontSize: 13,
          lineHeight: 20,
          color: EghuActionCreateColors.text,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              color: const Color(0xA61B1F3B),
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EghuActionCreateColors.soft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: eghuText(fontSize: 15, lineHeight: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerShimmer extends StatelessWidget {
  const _PickerShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFEFEFEF),
          highlightColor: Colors.white,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

class _PickerEmpty extends StatelessWidget {
  const _PickerEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: eghuText(
          fontSize: 15,
          lineHeight: 24,
          color: const Color(0xFF5B6078),
        ),
      ),
    );
  }
}

class _PickerError extends StatelessWidget {
  const _PickerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: eghuText(fontSize: 15, lineHeight: 24),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(Words.retry.tr())),
        ],
      ),
    );
  }
}

class _LoadingMoreTile extends StatelessWidget {
  const _LoadingMoreTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
