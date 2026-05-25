import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

enum ActionMenuCategory { eghu, industrialCollectors, technologicalDevices }

enum ActionMenuType { reinstall, detach, indicatorUpload }

class ActionMenuItem {
  const ActionMenuItem({
    required this.title,
    required this.iconPath,
    required this.category,
    required this.type,
    required this.isWide,
  });

  final Words title;
  final String iconPath;
  final ActionMenuCategory category;
  final ActionMenuType type;
  final bool isWide;

  static const List<ActionMenuItem> items = [
    ActionMenuItem(
      title: Words.actionEghuReinstall,
      iconPath: AppTools.icDashboardSpeed01,
      category: ActionMenuCategory.eghu,
      type: ActionMenuType.reinstall,
      isWide: false,
    ),
    ActionMenuItem(
      title: Words.actionEghuDetach,
      iconPath: AppTools.icDashboardSpeed01,
      category: ActionMenuCategory.eghu,
      type: ActionMenuType.detach,
      isWide: false,
    ),
    ActionMenuItem(
      title: Words.actionEghuIndicatorUpload,
      iconPath: AppTools.icDashboardSpeed01,
      category: ActionMenuCategory.eghu,
      type: ActionMenuType.indicatorUpload,
      isWide: true,
    ),
    ActionMenuItem(
      title: Words.actionIndustrialCollectorsReinstall,
      iconPath: AppTools.icDashboardSpeed02,
      category: ActionMenuCategory.industrialCollectors,
      type: ActionMenuType.reinstall,
      isWide: false,
    ),
    ActionMenuItem(
      title: Words.actionIndustrialCollectorsDetach,
      iconPath: AppTools.icDashboardSpeed02,
      category: ActionMenuCategory.industrialCollectors,
      type: ActionMenuType.detach,
      isWide: false,
    ),
    ActionMenuItem(
      title: Words.actionIndustrialCollectorsIndicatorUpload,
      iconPath: AppTools.icDashboardSpeed02,
      category: ActionMenuCategory.industrialCollectors,
      type: ActionMenuType.indicatorUpload,
      isWide: true,
    ),
    ActionMenuItem(
      title: Words.actionTechnologicalDevicesReinstall,
      iconPath: AppTools.icTool,
      category: ActionMenuCategory.technologicalDevices,
      type: ActionMenuType.reinstall,
      isWide: false,
    ),
    ActionMenuItem(
      title: Words.actionTechnologicalDevicesDetach,
      iconPath: AppTools.icTool,
      category: ActionMenuCategory.technologicalDevices,
      type: ActionMenuType.detach,
      isWide: false,
    ),
    ActionMenuItem(
      title: Words.actionTechnologicalDevicesIndicatorUpload,
      iconPath: AppTools.icTool,
      category: ActionMenuCategory.technologicalDevices,
      type: ActionMenuType.indicatorUpload,
      isWide: true,
    ),
  ];
}
