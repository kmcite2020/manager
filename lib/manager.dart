// ignore_for_file: public_member_api_docs, sort_constructors_first
library manager;

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef Listener = void Function(void Function());
typedef Creator<T> = T Function();
final _setStates = <Listener>[];
void _addListener(Listener listener) => _setStates.add(listener);
void _removeListener(Listener listener) => _setStates.remove(listener);
// void _removeAllListeners() => _listeners.clear();

class RM<T> {
  static late Box box;

  /// To enable persistence this method must be called and awaited in main();
  static Future<void> initStorage() async {
    await Hive.initFlutter();
    final info = await PackageInfo.fromPlatform();
    box = await Hive.openBox(info.appName);
  }

  factory RM.create(Creator<T> creator) => RM(creator);

  late T _state;
  final Creator<T> _creator;
  final String? key;
  final Persistence? persistence;

  RM(
    this._creator, {
    this.key,
    this.persistence,
  }) {
    _state = _creator();
  }

  T call([T? t]) {
    if (t != null) {
      if (_state != t) {
        _state = t;
        _notifyUI();
      }
    }
    return _state;
  }

  void _notifyUI() {
    for (final setState in _setStates) {
      setState(
        () {
          if (RM._logging) print(this);
        },
      );
    }
  }

  @override
  String toString() => '$runtimeType(value:$_state)';
  static bool _logging = false;
  static void setLogging(bool value) => _logging = value;
}

class Persistence {}

abstract class UI extends StatefulWidget {
  const UI({Key? key}) : super(key: key);

  @override
  ExtendedState createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<UI> {
  late Listener listener;
  @override
  void initState() {
    super.initState();
    listener = setState;
    _addListener(listener);
  }

  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    _removeListener(listener);
    super.dispose();
  }
}

// Map<String, dynamic> toJson<T extends ToJson>(T t) {
//   return t.toJson();
// }

// abstract class ToJson {
//   Map<String, dynamic> toJson<T>();
//   fromJson<T>(json);
// }

// class Save<T> {}
