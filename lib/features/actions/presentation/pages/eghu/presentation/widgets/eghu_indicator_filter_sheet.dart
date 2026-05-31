import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/api/global/global_api.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/models/global/global_model.dart';
import '../../../../../../../di.dart';
import '../../../../../../../global_widget/app_tools.dart';
import '../bloc/eghu_indicator_list_bloc.dart';
import 'create/eghu_action_form_fields.dart';
import 'eghu_action_filter_sheet.dart';
import 'eghu_calendar_dialog.dart';

class EghuIndicatorFilterBottomSheet extends StatefulWidget {
  const EghuIndicatorFilterBottomSheet({
    super.key,
    required this.initialFilter,
    this.source,
  });

  final EghuIndicatorListFilter initialFilter;
  final EghuActionFilterDataSource? source;

  @override
  State<EghuIndicatorFilterBottomSheet> createState() =>
      _EghuIndicatorFilterBottomSheetState();
}

class _EghuIndicatorFilterBottomSheetState
    extends State<EghuIndicatorFilterBottomSheet> {
  late final EghuActionFilterDataSource _source =
      widget.source ?? _GlobalIndicatorFilterDataSource(di.get<GlobalApi>());

  bool _loadingRegions = true;
  bool _loadingDistricts = false;
  String? _error;

  List<GlobalModel> _regions = const [];
  List<GlobalModel> _districts = const [];
  GlobalModel? _selectedRegion;
  GlobalModel? _selectedDistrict;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    _startDate = filter.startDate;
    _endDate = filter.endDate;
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _loadingRegions = true;
      _error = null;
    });

    try {
      final regions = await _source.getRegions();
      if (!mounted) return;

      final selectedRegion = _findById(regions, widget.initialFilter.regionId);
      setState(() {
        _regions = regions;
        _selectedRegion = selectedRegion;
        _loadingRegions = false;
      });

      final regionId = selectedRegion?.id;
      if (regionId != null) {
        await _loadDistricts(regionId, preselectInitial: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRegions = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadDistricts(
    int regionId, {
    bool preselectInitial = false,
  }) async {
    setState(() {
      _loadingDistricts = true;
      _error = null;
    });

    try {
      final districts = await _source.getDistricts(regionId);
      if (!mounted) return;

      setState(() {
        _districts = districts;
        _selectedDistrict = preselectInitial
            ? _findById(districts, widget.initialFilter.districtId)
            : null;
        _loadingDistricts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDistricts = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.86,
        decoration: const BoxDecoration(
          color: EghuActionCreateColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EghuActionCreateColors.strokeStrong,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Words.filters.tr(),
                      style: eghuText(
                        fontSize: 17,
                        lineHeight: 28,
                        fontWeight: FontWeight.w800,
                        color: EghuActionCreateColors.textStrong,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      _ErrorBanner(message: _error!, onRetry: _loadRegions),
                      const SizedBox(height: 12),
                    ],
                    _DateIntervalSection(
                      startDate: _startDate,
                      endDate: _endDate,
                      onPickStart: _pickStartDate,
                      onPickEnd: _pickEndDate,
                    ),
                    const SizedBox(height: 12),
                    _PickerField<GlobalModel>(
                      key: const Key('eghu-indicator-filter-region-field'),
                      label: Words.region.tr(),
                      value: _selectedRegion?.name,
                      hint: _loadingRegions
                          ? Words.loading.tr()
                          : Words.select.tr(),
                      enabled: !_loadingRegions && _regions.isNotEmpty,
                      items: _regions,
                      itemTitle: (item) => item.name ?? '',
                      selected: _selectedRegion,
                      isSame: (a, b) => a.id == b.id,
                      onSelected: (region) {
                        setState(() {
                          _selectedRegion = region;
                          _selectedDistrict = null;
                          _districts = const [];
                        });
                        final id = region.id;
                        if (id != null) _loadDistricts(id);
                      },
                    ),
                    const SizedBox(height: 12),
                    _PickerField<GlobalModel>(
                      key: const Key('eghu-indicator-filter-district-field'),
                      label: Words.district.tr(),
                      value: _selectedDistrict?.name,
                      hint: _selectedRegion == null
                          ? Words.selectRegionFirst.tr()
                          : _loadingDistricts
                          ? Words.loading.tr()
                          : Words.select.tr(),
                      enabled:
                          _selectedRegion != null &&
                          !_loadingDistricts &&
                          _districts.isNotEmpty,
                      items: _districts,
                      itemTitle: (item) => item.name ?? '',
                      selected: _selectedDistrict,
                      isSame: (a, b) => a.id == b.id,
                      onSelected: (district) {
                        setState(() => _selectedDistrict = district);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                media.padding.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('eghu-indicator-filter-clear'),
                      onPressed: () => Navigator.pop(
                        context,
                        const EghuIndicatorListFilter(),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: EghuActionCreateColors.textStrong,
                        side: const BorderSide(
                          color: EghuActionCreateColors.strokeStrong,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(Words.clear.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('eghu-indicator-filter-apply'),
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: EghuActionCreateColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(Words.apply.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await pickEghuDate(
      context,
      initialDate: _startDate ?? _endDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5, 12, 31),
      dialogKey: const Key('eghu-indicator-filter-from-calendar-dialog'),
    );
    if (picked == null || !mounted) return;
    _setDateRange(start: picked, end: _endDate);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await pickEghuDate(
      context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5, 12, 31),
      dialogKey: const Key('eghu-indicator-filter-to-calendar-dialog'),
    );
    if (picked == null || !mounted) return;
    _setDateRange(start: _startDate, end: picked);
  }

  void _setDateRange({DateTime? start, DateTime? end}) {
    final normalizedStart = start == null ? null : _dateOnly(start);
    final normalizedEnd = end == null ? null : _dateOnly(end);
    setState(() {
      if (normalizedStart != null &&
          normalizedEnd != null &&
          normalizedStart.isAfter(normalizedEnd)) {
        _startDate = normalizedEnd;
        _endDate = normalizedStart;
      } else {
        _startDate = normalizedStart;
        _endDate = normalizedEnd;
      }
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      EghuIndicatorListFilter(
        startDate: _startDate,
        endDate: _endDate,
        regionId: _selectedRegion?.id,
        regionName: _selectedRegion?.name,
        districtId: _selectedDistrict?.id,
        districtName: _selectedDistrict?.name,
      ),
    );
  }
}

class _GlobalIndicatorFilterDataSource implements EghuActionFilterDataSource {
  const _GlobalIndicatorFilterDataSource(this._api);

  final GlobalApi _api;

  @override
  Future<List<GlobalModel>> getRegions() => _api.getRegions();

  @override
  Future<List<GlobalModel>> getDistricts(int regionId) =>
      _api.getDistricts(regionId);
}

class _DateIntervalSection extends StatelessWidget {
  const _DateIntervalSection({
    required this.startDate,
    required this.endDate,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Words.dateRange.tr(),
          style: eghuText(fontSize: 11, lineHeight: 16, letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _DateField(
                key: const Key('eghu-indicator-filter-date-from-field'),
                label: Words.dateFrom.tr(),
                date: startDate,
                onTap: onPickStart,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateField(
                key: const Key('eghu-indicator-filter-date-to-field'),
                label: Words.dateTo.tr(),
                date: endDate,
                onTap: onPickEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = date == null ? null : DateFormat('dd.MM.yyyy').format(date!);
    return Material(
      color: EghuActionCreateColors.field,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EghuActionCreateColors.stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: eghuText(
                    fontSize: 13,
                    lineHeight: 20,
                    color: value == null
                        ? EghuActionCreateColors.textSub
                        : EghuActionCreateColors.text,
                  ),
                ),
              ),
              AppTools.svg(AppTools.icCalendar, width: 18, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField<T> extends StatelessWidget {
  const _PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.enabled,
    required this.items,
    required this.itemTitle,
    required this.selected,
    required this.isSame,
    required this.onSelected,
  });

  final String label;
  final String? value;
  final String hint;
  final bool enabled;
  final List<T> items;
  final String Function(T) itemTitle;
  final T? selected;
  final bool Function(T a, T b) isSame;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return EghuSelectorField(
      label: label,
      value: value?.trim().isNotEmpty == true ? value! : hint,
      placeholder: value?.trim().isNotEmpty != true,
      onTap: enabled ? () => _openPicker(context) : () {},
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterPickerSheet<T>(
        title: label,
        items: items,
        itemTitle: itemTitle,
        selected: selected,
        isSame: isSame,
      ),
    );
    if (result != null) onSelected(result);
  }
}

class _FilterPickerSheet<T> extends StatefulWidget {
  const _FilterPickerSheet({
    required this.title,
    required this.items,
    required this.itemTitle,
    required this.selected,
    required this.isSame,
  });

  final String title;
  final List<T> items;
  final String Function(T) itemTitle;
  final T? selected;
  final bool Function(T a, T b) isSame;

  @override
  State<_FilterPickerSheet<T>> createState() => _FilterPickerSheetState<T>();
}

class _FilterPickerSheetState<T> extends State<_FilterPickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (item) => widget
              .itemTitle(item)
              .toLowerCase()
              .contains(_query.trim().toLowerCase()),
        )
        .toList();
    final media = MediaQuery.of(context);

    return Container(
      height: media.size.height * 0.72,
      decoration: const BoxDecoration(
        color: EghuActionCreateColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: EghuActionCreateColors.strokeStrong,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: eghuText(
                    fontSize: 17,
                    lineHeight: 28,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    key: const Key('eghu-indicator-filter-picker-search'),
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: Words.search.tr().replaceAll('...', ''),
                      filled: true,
                      fillColor: EghuActionCreateColors.field,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(
                        EghuActionCreateColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                media.padding.bottom + 16,
              ),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isSelected =
                    widget.selected != null &&
                    widget.isSame(item, widget.selected as T);
                return Material(
                  color: isSelected
                      ? EghuActionCreateColors.primary.withValues(alpha: 0.10)
                      : EghuActionCreateColors.field,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context, item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.itemTitle(item),
                              style: eghuText(fontSize: 13, lineHeight: 20),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: EghuActionCreateColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: eghuText(fontSize: 13, lineHeight: 20)),
          ),
          TextButton(onPressed: onRetry, child: Text(Words.retry.tr())),
        ],
      ),
    );
  }
}

GlobalModel? _findById(List<GlobalModel> items, int? id) {
  if (id == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

OutlineInputBorder _inputBorder([Color color = EghuActionCreateColors.stroke]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}
