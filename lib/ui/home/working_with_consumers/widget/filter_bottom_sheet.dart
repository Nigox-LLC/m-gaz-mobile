import 'package:flutter/material.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/di.dart';
import 'package:m_gaz/global_widget/global_dropdown.dart';

class FilterResult {
  final int? regionId;
  final int? districtId;
  final bool cleared;

  const FilterResult({this.regionId, this.districtId, this.cleared = false});

  factory FilterResult.clear() => const FilterResult(cleared: true);
}

class FilterBottomSheet extends StatefulWidget {
  final int? initialRegionId;
  final int? initialDistrictId;

  const FilterBottomSheet({
    super.key,
    this.initialRegionId,
    this.initialDistrictId,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final GlobalApi _api = di.get<GlobalApi>();

  bool _loadingRegions = false;
  bool _loadingDistricts = false;
  String? _error;

  List<GlobalModel> _regions = const [];
  List<GlobalModel> _districts = const [];

  GlobalModel? _selectedRegion;
  GlobalModel? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _loadingRegions = true;
      _error = null;
    });

    try {
      final regions = await _api.getRegions();
      if (!mounted) return;

      GlobalModel? preselectedRegion;
      if (widget.initialRegionId != null) {
        for (final r in regions) {
          if (r.id == widget.initialRegionId) {
            preselectedRegion = r;
            break;
          }
        }
      }

      setState(() {
        _regions = regions;
        _selectedRegion = preselectedRegion;
        _loadingRegions = false;
      });

      if (preselectedRegion?.id != null) {
        _loadDistricts(preselectedRegion!.id!, preselectInitial: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRegions = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadDistricts(int regionId, {bool preselectInitial = false}) async {
    setState(() {
      _loadingDistricts = true;
    });

    try {
      final districts = await _api.getDistricts(regionId);
      if (!mounted) return;

      GlobalModel? preselectedDistrict;
      if (preselectInitial && widget.initialDistrictId != null) {
        for (final d in districts) {
          if (d.id == widget.initialDistrictId) {
            preselectedDistrict = d;
            break;
          }
        }
      }

      setState(() {
        _districts = districts;
        _selectedDistrict = preselectedDistrict;
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

  void _onApply() {
    Navigator.pop(
      context,
      FilterResult(
        regionId: _selectedRegion?.id,
        districtId: _selectedDistrict?.id,
      ),
    );
  }

  void _onClear() {
    Navigator.pop(context, FilterResult.clear());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        height: mq.size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filtrlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: AppColors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadRegions,
                              child: const Text('Qayta'),
                            ),
                          ],
                        ),
                      ),
                    GenericSelectableField<GlobalModel>(
                      title: 'Viloyat',
                      items: _regions,
                      selectedItem: _selectedRegion,
                      hintText: _loadingRegions
                          ? 'Yuklanmoqda...'
                          : 'Tanlang',
                      onChanged: (item) {
                        setState(() {
                          _selectedRegion = item;
                          _selectedDistrict = null;
                          _districts = const [];
                        });
                        if (item.id != null) {
                          _loadDistricts(item.id!);
                        }
                      },
                      getTitle: (m) => m.name ?? '',
                      isEqual: (a, b) => a.id == b.id,
                      readOnly: _loadingRegions || _regions.isEmpty,
                    ),
                    GenericSelectableField<GlobalModel>(
                      title: 'Tuman',
                      items: _districts,
                      selectedItem: _selectedDistrict,
                      hintText: _selectedRegion == null
                          ? 'Avval viloyat tanlang'
                          : _loadingDistricts
                              ? 'Yuklanmoqda...'
                              : 'Tanlang',
                      onChanged: (item) {
                        setState(() => _selectedDistrict = item);
                      },
                      getTitle: (m) => m.name ?? '',
                      isEqual: (a, b) => a.id == b.id,
                      readOnly: _selectedRegion == null ||
                          _loadingDistricts ||
                          _districts.isEmpty,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, mq.padding.bottom + 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onClear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.c181D27),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Tozalash',
                        style: TextStyle(
                          color: AppColors.c181D27,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.c181D27,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Qo'llash",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
