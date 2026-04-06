import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveBase {
  late final Box _apiBox;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init("${dir.path}/crm_imv");
    _apiBox = await Hive.openBox("api");
  }

  Box get apiBox => _apiBox;
}
