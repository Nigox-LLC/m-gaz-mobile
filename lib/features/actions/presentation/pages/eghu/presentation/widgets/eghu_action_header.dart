import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class EghuActionHeader extends StatelessWidget {
  const EghuActionHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onAdd,
    this.searchController,
    this.onSearchChanged,
    this.onFilter,
    this.filterActive = false,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilter;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              _BackButton(onTap: onBack ?? () => Navigator.maybePop(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    height: 28 / 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _AddActionButton(onTap: onAdd),
            ],
          ),
        ),
        const SizedBox(height: 4),
        EghuSearchFilterBar(
          controller: searchController,
          onChanged: onSearchChanged,
          onFilter: onFilter,
          filterActive: filterActive,
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: Color(0xFF141B34),
          ),
        ),
      ),
    );
  }
}

class _AddActionButton extends StatelessWidget {
  const _AddActionButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Material(
        color: const Color(0xFF3F57B3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTools.svg(AppTools.icFileText, width: 20, height: 20),
                const SizedBox(width: 8),
                Text(
                  Words.add.tr(),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 20 / 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFCFCFC),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EghuSearchFilterBar extends StatelessWidget {
  const EghuSearchFilterBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilter,
    this.filterActive = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EghuSearchField(controller: controller, onChanged: onChanged),
        ),
        const SizedBox(width: 12),
        Material(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: const Key('eghu-list-filter-button'),
            borderRadius: BorderRadius.circular(16),
            onTap: onFilter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: filterActive
                          ? const Color(0xFF526ED3)
                          : const Color(0xFFE8E8E8),
                    ),
                  ),
                  child: AppTools.svg(
                    AppTools.icFilterIcon,
                    width: 16,
                    height: 16,
                  ),
                ),
                if (filterActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF526ED3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EghuSearchField extends StatelessWidget {
  const EghuSearchField({super.key, this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        key: const Key('eghu-list-search-field'),
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.manrope(
          fontSize: 13,
          height: 20 / 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF202020),
        ),
        decoration: InputDecoration(
          hintText: Words.search.tr().replaceAll('...', ''),
          hintStyle: GoogleFonts.manrope(
            fontSize: 13,
            height: 20 / 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFBBBBBB),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: AppTools.svg(AppTools.icSearchIcon, width: 24, height: 24),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(const Color(0xFF526ED3)),
        ),
      ),
    );
  }

  OutlineInputBorder _border([Color color = const Color(0xFFE8E8E8)]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }
}
