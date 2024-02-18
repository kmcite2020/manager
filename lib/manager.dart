import 'manager.dart';
export 'package:manager/example_app/bloc.dart';
export 'package:manager/example_app/cubit.dart';

export 'dart:convert';
export 'package:flutter/material.dart' hide State;
export 'package:hive_flutter/hive_flutter.dart';
export 'package:manager/extensions.dart';
export 'package:manager/state_manager/ui/ui.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'navigator.dart';

class Persistor<T> {
  final String key;
  final ToJson<T> toJson;
  final FromJson<T> fromJson;
  Persistor({
    required this.key,
    required this.toJson,
    required this.fromJson,
  });
}

typedef ToJson<T> = Map<String, dynamic> Function(T s);
typedef FromJson<T> = T Function(Map<String, dynamic> json);

Future<void> _initStorage() async {
  await Hive.initFlutter();
  final info = await PackageInfo.fromPlatform();
  box = await Hive.openBox(info.appName);
}

/// Surface API
class RM<T> {
  late final RMI<T> _rm;
  Persistor<T>? _persistor;
  bool get persistable => _persistor.isNotNull;

  RM(
    T Function() creator, {
    T? initialState,
    Persistor<T>? persistor,
  }) : _persistor = persistor {
    if (persistable) {
      persistor!;
      final fromJsonType = persistor.fromJson.runtimeType;
      if (fromJsonType != FromJson<T>) {
        throw Exception(
            'Please give proper FromJson. current: ${fromJsonType} for type: $T');
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

    return _state;
  }

  T get _state {
    try {
      if (persistable) {
        final persisted = box.get(_persistor?.key) as String?;
        if (persisted.isNotNull) {
          final decoded = jsonDecode(persisted!) as Map<String, dynamic>?;
          if (decoded.isNotNull) {
            final data = _persistor?.fromJson.call(decoded!);
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

mixin ReplayMixin<T> {
  final List<T> history = [];
  bool get replayable => history.isNotEmpty;
  void undo();
  void redo();
}

late Box box; // Persistence Box

void _runApp(Widget home, [Function? function]) async {
  function?.call();
  await _initStorage();
  runApp(home);
}

void _clearStorage() async => await box.clear();
