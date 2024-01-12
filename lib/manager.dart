library manager;

/// GLOBAL SETTINGS
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manager/main.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'stream_injected.dart';
part 'ui.dart';
part 'future_injected.dart';
part 'injected.dart';
part 'navigator_injected.dart';
part 'persistable_injected.dart';
part 'simple_injected.dart';

typedef Notifier = void Function(void Function()); // setState Signature
typedef ToJson<T> = Map<String, dynamic> Function(T s); // toJson Signature
typedef Reader<T> = T Function(String key);
typedef Writer<T> = Future<void> Function(String key, T value);
final notifiers = <Notifier>[]; // List of Setstates
final injecteds = <Injected>[]; // List of Injecteds
ToJson toJson = (s) => s.toJson(); // toJson Impl
void inform(String message) => dev.log(message); // Logger

late Box box; // Persistence Box
/// Storage Initializaer
Future<void> _initStorage() async {
  await Hive.initFlutter();
  final info = await PackageInfo.fromPlatform();
  box = await Hive.openBox(info.appName);
}

/// Injected Resets
void _resetStates() {
  for (final injected in injecteds) {
    injected.reset();
  }
}

Future<void> _deletePersistentStates() => box.clear();

/// Surface API
abstract class RM<T> {
  static const deletePersistentStates = _deletePersistentStates;
  static const initStorage = _initStorage;
  static const resetStates = _resetStates;

  /// Create a persistent state, which survives across restarts of an app
  /// State objects should only be created by Freezed compatible by Freezed
  static PersistableInjected<T> persistent<T>(
    T Function() invoker, {
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return PersistableInjected<T>(
      invoker,
      key: key,
      fromJson: fromJson,
    );
  }

  /// Simple State Management
  static SimpleInjected<T> simple<T>(
    T Function() creator,
  ) {
    return SimpleInjected<T>(creator);
  }

  /// Not recommended yet
  /// Cache a Future and use it anywhere
  static FutureInjected<T> future<T>(
    Future<T> Function() creator,
  ) {
    return FutureInjected<T>(creator);
  }

  /// Not recommended yet
  /// Create a stream of data and use it in UI.
  /// Currently its a single time subscription.
  static StreamInjected<T> stream<T>(Stream<T> Function() creator) {
    return StreamInjected(creator);
  }

  /// Use this package Imperative Navigation system. Set this [navigatorKey]
  /// to [MaterialApp]'s [navigatorKey]. Then use [navigator] variable
  /// of this package to use navigation.
  static GlobalKey<NavigatorState> get navigatorKey => navigator.key;
}
