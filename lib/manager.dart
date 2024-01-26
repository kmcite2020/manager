library manager;

/// GLOBAL SETTINGS
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manager/reactive_x.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'stream_injected.dart';
part 'future_injected.dart';
part 'injected.dart';
part 'navigator_injected.dart';
part 'persistable_injected.dart';
part 'simple_injected.dart';

typedef Notifier = void Function(void Function()); // setState Signature
typedef ToJson<T> = Map<String, dynamic> Function(T s); // toJson Signature
typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef Reader<T> = T Function(String key);
typedef Writer<T> = Future<void> Function(String key, T value);
final notifiers = <Notifier>[]; // List of Setstates
final injecteds = <Injected>[]; // List of Injecteds
ToJson toJson = (s) => s.toJson(); // toJson Impl
void inform(String message) => dev.log(message); // Logger

late Box box; // Persistence Box
/// Storage Initializer
Future<void> _initStorage() async {
  await Hive.initFlutter();
  final info = await PackageInfo.fromPlatform();
  box = await Hive.openBox(info.appName);
}

Future<void> _deletePersistentStates() => box.clear();

/// Surface API
abstract class RM<T> {
  static const deletePersistentStates = _deletePersistentStates;
  static const initStorage = _initStorage;

  /// Cache any type
  static Reading<T> readable<T>(T value) => Reading(value);

  /// Cache any type -> with side-effects support
  static Writable<T> writable<T>(T value) {
    return Writable(value);
  }

  /// Persist Freezed Type
  static persistent<T>(
    T defaultValue, {
    required FromJson<T> fromJson,
  }) {
    return;
  }

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
}
