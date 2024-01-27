import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'navigator_injected.dart';
import 'state_manager/caching/cached.dart';
import 'state_manager/management/complex.dart';
import 'state_manager/caching/future_cached.dart';
import 'state_manager/management/manager.dart';
import 'state_manager/management/simple.dart';
import 'dart:developer' as dev;

import 'state_manager/caching/stream_cached.dart';

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
  static const deletePersistentStates = _deletePersistentStates;
  static const initStorage = _initStorage;

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

  /// BLOC
  static M manager<M extends Manager>(M manager) => manager;

  /// NOTIFIER - CUBIT
  static C complex<C extends Complex>(C complex) => complex;

  /// GLOBAL
  static Simple<T> simple<T>(Creator<T> creator) => Simple(creator);

  /// RIVERPOD LIKE CACHING
  static Cached<T> cached<T>(T cache) => Cached(cache);

  /// RIVERPOD LIKE CACHING FUTURE
  static FutureCached<T> future<T>(FutureCreator<T> creator) =>
      FutureCached(creator);

  /// RIVERPOD LIKE CACHING STREAM
  static StreamCached<T> stream<T>(StreamCreator<T> creator) =>
      StreamCached(creator);
}
