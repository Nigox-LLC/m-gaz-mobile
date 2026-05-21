import 'package:flutter/material.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import '../core/utils/colors.dart';
import '../core/utils/style.dart';

class GenericSelectableField<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String hintText;
  final void Function(T) onChanged;
  final String Function(T) getTitle;
  final bool Function(T a, T b) isEqual;
  final String? Function(T?)? validator;
  final bool readOnly;

  const GenericSelectableField({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.hintText,
    required this.onChanged,
    required this.getTitle,
    required this.isEqual,
    this.validator,
    this.readOnly = false,
  });

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContent<T>(
        items: items,
        selectedItem: selectedItem,
        getTitle: getTitle,
        isEqual: isEqual,
        onSelect: (item) {
          onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.style600),
        6.getH(),
        GestureDetector(
          onTap: readOnly ? null : () => _openBottomSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(color: AppColors.white),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem != null ? getTitle(selectedItem!) : hintText,
                    style: AppTextStyles.style500.copyWith(
                      color: selectedItem != null
                          ? AppColors.black
                          : AppColors.c717680,
                    ),
                  ),
                ),
                if (!readOnly)
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.c717680,
                  ),
              ],
            ),
          ),
        ),
        if (validator != null)
          Builder(
            builder: (_) {
              final error = validator!(selectedItem);
              if (error == null) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 6.h, left: 12.w),
                child: Text(
                  error,
                  style: AppTextStyles.style400.copyWith(
                    color: Colors.red,
                    fontSize: 12.w,
                  ),
                ),
              );
            },
          ),
        16.getH(),
      ],
    );
  }
}

class _BottomSheetContent<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) getTitle;
  final bool Function(T a, T b) isEqual;
  final void Function(T) onSelect;

  const _BottomSheetContent({
    required this.items,
    required this.selectedItem,
    required this.getTitle,
    required this.isEqual,
    required this.onSelect,
  });

  @override
  State<_BottomSheetContent<T>> createState() => _BottomSheetContentState<T>();
}

class _BottomSheetContentState<T> extends State<_BottomSheetContent<T>> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (e) => widget.getTitle(e).toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      child: Column(
        children: [
          12.getH(),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          16.getH(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: Words.search.tr(),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: AppColors.cF5F5F5,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          16.getH(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final selected =
                    widget.selectedItem != null &&
                    widget.isEqual(item, widget.selectedItem!);

                return InkWell(
                  onTap: () => widget.onSelect(item),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.c1570EF.withValues(alpha: 0.1)
                          : AppColors.cF5F5F5,
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.getTitle(item),
                            style: AppTextStyles.style500.copyWith(
                              color: selected
                                  ? AppColors.c1570EF
                                  : AppColors.black,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle, color: AppColors.c1570EF),
                      ],
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
