import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Logging mechanism
void inform(String message) {
  dev.log(message);
}

/// Implementation for persistence of States
class Saver {
  late Box _box;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      final info = await PackageInfo.fromPlatform();
      _box = await Hive.openBox(info.appName);
    } catch (e) {
      // Handle the error here, you can log it or show a user-friendly message.
      inform('Error during initialization: $e');
    }
  }

  String? read(String key) {
    try {
      return _box.get(key);
    } catch (e) {
      inform('Error during read operation: $e');
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _box.put(key, value);
    } catch (e) {
      inform('Error during write operation: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
    } catch (e) {
      inform('Error during delete operation: $e');
    }
  }

  Future<int> clearAll() async {
    try {
      return await _box.clear();
    } catch (e) {
      inform('Error during clearAll operation: $e');
      return 0;
    }
  }
}

class Save<T> {
  String key;
  T Function(Map<String, dynamic> json) fromJson;
  Map<String, dynamic> Function(T s) toJson;
  Save({
    required this.key,
    required this.fromJson,
    required this.toJson,
  });
}

class RM<T> {
  static final saver = Saver();
  RM.create(
    T Function() creator, {
    Save<T>? save,
  }) : _save = save {
    _initState(creator);
  }
  RM.future(
    Future<T> Function() creator, {
    this.initialState,
    Save<T>? save,
  }) : _save = save {
    _initState(creator);
  }
  RM.stream(
    Stream<T> Function() creator, {
    this.initialState,
    Save<T>? save,
  }) : _save = save {
    _initState(creator);
  }
  static final notifiers = <Notifier>[];

  /// Save Configuration
  final Save<T>? _save;
  bool get persistable => _save != null;
  String? get key => _save?.key;
  T Function(Map<String, dynamic>)? get fromJson => _save?.fromJson;
  Map<String, dynamic> Function(T)? get toJson => _save?.toJson;

  T? initialState;
  T? _state;

  late StreamSubscription<T>? streamSubscription;

  set state(T state) {
    _state = state;
    if (persistable) {
      final json = toJson?.call(state);
      if (json != null) {
        saver.write(
          _save!.key,
          jsonEncode(json),
        );
      }
    }
    _notify();
  }

  T get state {
    readPersistentStateIfPersistable(key);
    _state ??= initialState;
    return _state!;
  }

  T call([T? newState]) {
    if (newState != null) {
      state = newState;
    }
    return state;
  }

  bool get loading => _state == null;

  void _initState(creator) async {
    if (creator is Future<T> Function()) {
      state = await creator();
      if (readPersistentStateIfPersistable(key)) return;
    } else if (creator is Stream<T> Function()) {
      streamSubscription = creator().listen((newState) => state = newState);
      if (readPersistentStateIfPersistable(key)) return;
    } else {
      if (readPersistentStateIfPersistable(key)) return;
      state = creator();
    }
  }

  bool readPersistentStateIfPersistable(String? key) {
    if (persistable) {
      final str = saver.read(key!);
      if (str != null) {
        _state = fromJson?.call(jsonDecode(str));
      }
    }
    return persistable;
  }

  void _notify() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        for (final notifier in notifiers) {
          notifier(
            // ignore: avoid_inform
            () => inform("$runtimeType $timeStamp"),
          );
        }
      },
    );
  }

  void dispose() => streamSubscription?.cancel();

  static Future<void> initStorage() {
    return saver.init();
  }
}

abstract class UI extends StatefulWidget {
  const UI({super.key});

  @override
  State<UI> createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<UI> {
  late Notifier notifier;
  @override
  void initState() {
    super.initState();
    notifier = setState;
    RM.notifiers.add(notifier);
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }

  @override
  void dispose() {
    RM.notifiers.remove(notifier);
    super.dispose();
  }
}

typedef Notifier = void Function(void Function());

class ReactiveModelBuilder extends UI {
  const ReactiveModelBuilder({
    super.key,
    required this.builder,
    required this.reactiveModel,
  });

  final Widget Function(BuildContext context) builder;
  final RM reactiveModel;
  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

extension RMExtensions<T> on RM<T> {
  Widget build(Widget Function(T state) widget) {
    return ReactiveModelBuilder(
      builder: (builder) => widget(state),
      reactiveModel: this,
    );
  }
}
