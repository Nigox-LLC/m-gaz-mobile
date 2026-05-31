import 'package:flutter/material.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/pages/eghu_action_create_page.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/eghu_action_list_page.dart';

class EghuTakeOffPage extends StatelessWidget {
  const EghuTakeOffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EghuActionListPage(
      title: Words.actionEghuDetach.tr(),
      useRemoteList: true,
      actionType: ActionMenuType.detach,
      onAdd: () => Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) =>
              const EghuActionCreatePage(actionType: ActionMenuType.detach),
        ),
      ),
    );
  }
}
