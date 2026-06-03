import 'package:flutter/material.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/pages/eghu_action_create_page.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_bottom_sheets.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/eghu_action_list_page.dart';

class EghuResetPage extends StatelessWidget {
  final String? facial;
  final EghuActionPreselection? preselection;
  const EghuResetPage({super.key, this.facial, this.preselection});

  @override
  Widget build(BuildContext context) {
    return EghuActionListPage(
      title: Words.actionEghuReinstall.tr(),
      useRemoteList: true,
      actionType: ActionMenuType.reinstall,
      facial: facial,
      onAdd: () => Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => EghuActionCreatePage(
            actionType: ActionMenuType.reinstall,
            preselection: preselection,
          ),
        ),
      ),
    );
  }
}
