// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'manager.dart';

late Box storage;

class PersistentSparkle<T> extends ISparkle<T> {
  static Future<void> get init async {
    await Hive.initFlutter();
    final app = await PackageInfo.fromPlatform();
    storage = await Hive.openBox('${app.appName}_${app.version}');
  }

  PersistentSparkle(
    this.initialState, {
    required this.key,
    required this.fromJson,
  }) {
    read();
  }
  final T Function(Map<String, dynamic>) fromJson;
  final String key;
  void read() {
    final storedValue = storage.get(key);
    if (storedValue == null) {
      return;
    }

    final json = jsonDecode(storedValue);
    if (json == null) {
      return;
    }

    final value = fromJson(json);
    if (value == null) {
      return;
    }
    set(value);
  }

  void write() async {
    try {
      final resultOfGet = (get as dynamic).toJson();
      if (resultOfGet is Map) {
        await storage.put(
          key,
          jsonEncode(resultOfGet),
        );
      } else if (resultOfGet is String) {
        storage.put(key, resultOfGet);
      } else {
        throw FlutterError('Unexpected result of toJson()');
      }
    } catch (e) {
      print('Error in write(): $e');
      rethrow;
    }
  }

  @override
  void set(T newValue) {
    super.set(newValue);
    write();
  }

  @override
  final initialState;
}
