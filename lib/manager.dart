import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manager/extensions.dart';
import 'package:manager/state_manager/ui/ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'navigator.dart';

typedef Persistor<T> = ({
  String key,
  ToJson<T> toJson,
  FromJson<T> fromJson,
});

typedef ToJson<T> = Map<String, dynamic> Function(T s);
typedef FromJson<T> = T Function(Map<String, dynamic> json);

Future<void> _initStorage() async {
  await Hive.initFlutter();
  final info = await PackageInfo.fromPlatform();
  box = await Hive.openBox(info.appName);
}

/// Surface API
class RM<T> with PersistorMixin<T> {
  late final RMI<T> _rm;
  factory RM(
    T value, {
    Persistor<T>? persistor,
  }) =>
      RM.create(
        () => value,
        initialState: value,
        persistor: persistor,
      );
  RM.create(
    T Function() creator, {
    T? initialState,
    Persistor<T>? persistor,
  }) {
    _persistor = persistor;
    if (persistable) {
      final found = box.containsKey(persistor?.key);
      if (found) {
        throw Exception(
            'Please provide a different key. current: ${persistor!.key}');
      }
      final fromJsonType = persistor!.fromJson.runtimeType;
      if (fromJsonType != FromJson<T>) {
        throw Exception(
            'Please give proper FromJson. current: ${fromJsonType}');
      }
      final toJsonType = persistor.toJson.runtimeType;
      if (toJsonType != ToJson<T>) {
        throw Exception('Please give proper ToJson. current: ${toJsonType}');
      }
    }
    _rm = RMI(
      creator: creator,
      initialState: initialState,
      autoDisposeWhenNotUsed: false,
      stateInterceptorGlobal: null,
    );
  }

  T call([T? t]) {
    if (t != null) {
      if (persistable) {
        final encodedData = jsonEncode(_persistor?.toJson(t));
        box.put(_persistor?.key, encodedData);
      }
      _rm.state = t;
      return t;
    }

    return _;
  }

  T get _ {
    try {
      if (persistable) {
        final persisted = box.get(_persistor?.key);
        if (persisted.isNotNull) {
          final decoded = jsonDecode(persisted);
          if (decoded.isNotNull) {
            final data = _persistor?.fromJson.call(decoded);
            if (data.isNotNull) {
              _rm.state = data!;
            } else {
              throw Exception('$data => NullException');
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return _rm.state;
  }

  static final runApp = _runApp;
  static Box get storage => box;
  static final clearStorage = _clearStorage;
  static GlobalKey<NavigatorState> get navigatorKey => navigator.key;
  static final toPage = navigator.toPage;
}

mixin PersistorMixin<T> {
  Persistor<T>? _persistor;
  bool get persistable => _persistor.isNotNull;
}

mixin ReplayMixin<T> {
  final List<T> history = [];
  bool get replayable => history.isNotEmpty;
  void undo();
  void redo();
}

late Box box; // Persistence Box
void _runApp(Widget app) async {
  await _initStorage();
  runApp(app);
}

void _clearStorage() async => await box.clear();
