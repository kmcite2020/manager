import 'package:hive_flutter/hive_flutter.dart' as hive;
import 'package:manager/manager.dart';

class HiveStorage implements IPersistStore {
  late final hive.Box box;

  @override
  Future<void> delete(String key) => box.delete(key);

  @override
  Future<void> deleteAll() => box.clear();

  @override
  Future<void> init() async {
    final appInfo = await PackageInfo.fromPlatform();
    await hive.Hive.initFlutter();
    box = await hive.Hive.openBox(appInfo.appName);
  }

  @override
  Object? read(String key) {
    return box.get(key);
  }

  @override
  Future<void> write<T>(String key, T value) => box.put(key, value);
}
