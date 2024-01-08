// ignore_for_file: public_member_api_docs, sort_constructors_first
library manager;

import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef Listener = void Function(void Function());
typedef Creator<T> = T Function();
final _setStates = <Listener>[];
void _addListener(Listener listener) => _setStates.add(listener);
void _removeListener(Listener listener) => _setStates.remove(listener);
void removeAllListeners() => _setStates.clear();

final persistenceImpl = PersistenceImpl();

class RM<T> {
  static void logger(Object? payload) {
    dev.log(payload.toString());
  }

  static Future<void> initStorage() async {
    return await persistenceImpl.initStorage();
  }

  factory RM.create(
    Creator<T> creator, {
    PersistenceSettings<T>? persistenceSettings,
  }) =>
      RM(
        creator,
        persistenceSettings: persistenceSettings,
      );

  late T _state;
  final Creator<T> _creator;
  final PersistenceSettings<T>? persistenceSettings;

  RM(
    this._creator, {
    this.persistenceSettings,
  }) {
    _state = _creator();
    _initState();
  }
  void _initState() async {
    final key = persistenceSettings?.key;
    if (key != null) {
      final json = persistenceImpl.read(key);
      if (json != null) {
        try {
          // Deserialize the state from JSON
          _state = await persistenceSettings!.fromJson!(json);
        } catch (e) {
          // Handle deserialization error
          logger('Error deserializing state: $e');
          _state = _creator();
        }
      } else {
        _state = _creator();
      }
    } else {
      _state = _creator();
    }
    _notifyUI();
  }

  T call([T? t]) {
    if (t != null) {
      if (_state != t) {
        _state = t;
        _notifyUI();
        _persistState();
      }
    }
    return _state!;
  }

  void _persistState() async {
    final key = persistenceSettings?.key;
    if (key != null) {
      final json = persistenceSettings!.toJson!(_state!);
      await persistenceImpl.write(key, json);
    }
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

class PersistenceSettings<T> {
  String? key;
  FutureOr<T> Function(String json)? fromJson;
  String Function(T s)? toJson;
  PersistenceSettings({
    this.key,
    this.fromJson,
    this.toJson,
  });
}

abstract class Persistence {
  Future<void> initStorage();
  Object? read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<int> clearAll();
}

class PersistenceImpl implements Persistence {
  static late Box box;
  @override
  Future<int> clearAll() => box.clear();

  @override
  Future<void> delete(String key) => box.delete(key);

  @override
  Future<void> initStorage() async {
    await Hive.initFlutter();
    final info = await PackageInfo.fromPlatform();
    box = await Hive.openBox(info.appName);
  }

  @override
  String? read(String key) => box.get(key);

  @override
  Future<void> write(String key, String value) => box.put(key, value);
}


// class RM<T> {
//   final _controller = StreamController<T>.broadcast();
//   T _lastValue;

//   RM(T initialValue) : _lastValue = initialValue {
//     _controller.add(initialValue);
//   }

//   Stream<T> get stream => _controller.stream;
//   T get value => _lastValue;

//   set value(T newValue) {
//     if (_lastValue != newValue) {
//       _lastValue = newValue;
//       _controller.add(newValue);
//     }
//   }

//   void dispose() {
//     _controller.close();
//   }
// }
