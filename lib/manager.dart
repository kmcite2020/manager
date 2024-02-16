import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';
import 'dart:developer' as dev;
import 'navigator_injected.dart';
import 'state_manager/caching/cached.dart';
import 'state_manager/management/complex.dart';
import 'state_manager/management/manager.dart';
import 'state_manager/management/simple.dart';

abstract class Created<T> extends _Created<T> {
  Created(T created) : super(creator: () => created);
}

abstract class CallableSupport<T> {
  T call([T? updatedValue]);
}

mixin class PersistenceSupport<T> {
  Persistor? persistor;

  bool get persistable => persistor != null;
}

abstract class StateSupport<T> {
  T get state;
  set state(T updatedValue);
}

class _Created<T> extends ReactiveModelImp<T>
    with PersistenceSupport<T>
    implements CallableSupport<T>, StateSupport<T> {
  _Created({
    required super.creator,
    super.initialState,
    super.autoDisposeWhenNotUsed = false,
    super.stateInterceptorGlobal,
    this.onChange,
    Persistor<T>? persistor,
  }) {
    persistor = persistor;
  }
  T call([T? newState]) {
    if (newState != null) state = newState;
    return state;
  }

  @override
  T get state {
    try {
      if (persistable) {
        final rawData = box.get(persistor?.key);
        if (rawData != null) {
          final decodedData = jsonDecode(rawData);
          if (decodedData != null) {
            final cachedData = persistor?.fromJson.call(decodedData);
            if (cachedData != null) {
              super.state = cachedData;
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return super.state;
  }

  @override
  set state(T value) {
    if (persistable) {
      final encodedData = jsonEncode(persistor?.toJson(value));
      box.put(persistor?.key, encodedData);
    }
    onChange?.call(value);
    super.state = value;
  }

  final void Function(T state)? onChange;
}

extension TypeExtensions<T> on T {
  _Created<T> obs({
    Persistor<T>? persistor,

    /// For side effects
    void Function(T state)? onChange,
  }) =>
      _Created<T>(
        creator: () => this,
        autoDisposeWhenNotUsed: false,
        persistor: persistor,
      );
}

extension CreatedExtensionsBool on _Created<bool> {
  void toggle() {
    state = !state;
  }
}

extension CreatedExtensionsInt on _Created<int> {
  void increment() => state++;
  void decrement() => state--;
}

typedef Persistor<T> = ({
  String key,
  Map<String, dynamic> Function(T state) toJson,
  T Function(Map<String, dynamic> json) fromJson,
});

final setStates = <Setstate>{};
typedef Setstate = void Function(void Function());
typedef ToJson<T> = Map<String, dynamic> Function(T s); // toJson Signature
typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef Reader<T> = T Function(String key);
typedef Writer<T> = Future<void> Function(String key, T value);
ToJson toJson = (s) => s.toJson(); // toJson Impl
void inform(String message) => dev.log(message); // Logger

late Box box; // Persistence Box
Future<void> _initStorage() async {
  await Hive.initFlutter();
  final info = await PackageInfo.fromPlatform();
  box = await Hive.openBox(info.appName);
}

Future<void> _deletePersistentStates() => box.clear();

/// Surface API
abstract class RM<T> {
  static Future<void> run(Widget app) async {
    await initStorage;
    runApp(app);
  }

  static const deletePersistentStates = _deletePersistentStates;
  static const initStorage = _initStorage;

  /// Persist Freezed Type
  static persistent<T>(
    T defaultValue, {
    required FromJson<T> fromJson,
  }) {}

  /// Persist with Custom ToJson/FromJson
  static persistentCustom<T>(
    T defaultValue, {
    required String key,
    required ToJson<T> toJson,
    required FromJson<T> fromJson,
  }) {}

  /// Create a persistent state, which survives across restarts of an app
  /// State objects should only be created by Freezed compatible by Freezed
  // static PersistableInjected<T> persistent<T>(
  //   T Function() invoker, {
  //   required String key,
  //   required T Function(Map<String, dynamic>) fromJson,
  // }) {
  //   return PersistableInjected<T>(
  //     invoker,
  //     key: key,
  //     fromJson: fromJson,
  //   );
  // }

  /// Use this package Imperative Navigation system. Set this [navigatorKey]
  /// to [MaterialApp]'s [navigatorKey]. Then use [navigator] variable
  /// of this package to use navigation.
  static GlobalKey<NavigatorState> get navigatorKey => navigator.key;

  /// BLOC
  static M manager<M extends Manager>(M manager) => manager;

  /// NOTIFIER - CUBIT
  static C complex<C extends Complex>(C complex) => complex;

  /// GLOBAL
  static SimpleManager<T> simple<T>(T Function() creator) =>
      SimpleManager(creator);

  /// RIVERPOD LIKE CACHING
  static Cached<T> cached<T>(T cache) => Cached(cache);

  /// RIVERPOD LIKE CACHING FUTURE
  // static FutureCached<T> future<T>(FutureCreator<T> creator) =>
  //     FutureCached(creator);

  // /// RIVERPOD LIKE CACHING STREAM
  // static StreamCached<T> stream<T>(StreamCreator<T> creator) =>
  //     StreamCached(creator);
}
