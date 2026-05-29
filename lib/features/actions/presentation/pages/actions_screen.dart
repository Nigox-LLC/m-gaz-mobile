import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/pages/eghu_reset.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/pages/eghu_take_off.dart';
import 'package:m_gaz/features/actions/presentation/widgets/action_card.dart';

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  static const double _contentMaxWidth = 350;
  static const double _horizontalPadding = 20;
  static const double _cardGap = 8;
  static const double _sectionGap = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final contentWidth = width >= _contentMaxWidth + 40
                ? _contentMaxWidth
                : (width - (_horizontalPadding * 2)).clamp(
                    0.0,
                    _contentMaxWidth,
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                16,
                _horizontalPadding,
                120,
              ),
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Words.actions.tr(),
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF1A1D2E),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 28 / 17,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ActionMenuGrid(
                        items: ActionMenuItem.items,
                        onTap: (item) => _handleActionTap(context, item),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleActionTap(BuildContext context, ActionMenuItem item) {
    final destination = switch ((item.category, item.type)) {
      (ActionMenuCategory.eghu, ActionMenuType.reinstall) =>
        const EghuResetPage(),
      (ActionMenuCategory.eghu, ActionMenuType.detach) =>
        const EghuTakeOffPage(),
      _ => null,
    };

    if (destination == null) {
      showToast(
        context,
        Words.comingSoon.tr(),
        backgroundColor: const Color(0xFF526ED3),
      );
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }
}

class _ActionMenuGrid extends StatelessWidget {
  const _ActionMenuGrid({required this.items, required this.onTap});

  final List<ActionMenuItem> items;
  final ValueChanged<ActionMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    final sections = <List<ActionMenuItem>>[
      items.sublist(0, 3),
      items.sublist(3, 6),
      items.sublist(6, 9),
    ];

    return Column(
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          _ActionSection(items: sections[index], onTap: onTap),
          if (index != sections.length - 1)
            const SizedBox(height: ActionsScreen._sectionGap),
        ],
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.items, required this.onTap});

  final List<ActionMenuItem> items;
  final ValueChanged<ActionMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    final compactItems = items.where((item) => !item.isWide).toList();
    final wideItem = items.singleWhere((item) => item.isWide);

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < compactItems.length; index++) ...[
              Expanded(
                child: ActionCard(
                  item: compactItems[index],
                  onTap: () => onTap(compactItems[index]),
                ),
              ),
              if (index != compactItems.length - 1)
                const SizedBox(width: ActionsScreen._cardGap),
            ],
          ],
        ),
        const SizedBox(height: ActionsScreen._cardGap),
        ActionCard(item: wideItem, onTap: () => onTap(wideItem)),
      ],
    );
  }
}
