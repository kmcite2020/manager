import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'spark.dart';

Future<void> redux(Widget app) => _init().then((_) => runApp(app));

late Directory appDir;

Future<void> _init() async {
  final directory = await getApplicationDocumentsDirectory();
  appDir = directory;
  // ignore: unused_local_variable
  final app = await PackageInfo.fromPlatform();
}

typedef T FromJson<T>(Map<String, dynamic> json);
typedef ListFromJson<T> = T Function(List<dynamic> jsonList);
typedef ListToJson<T> = List<dynamic> Function(T list);

abstract class Action<S> {
  Action() {
    if (store != null) {
      store?.call(this);
      print('\nKey: ${store?.persistence.key}\ntype: $S');
    }
  }
  final Token token = Token();
  FutureOr<void> before() {}
  FutureOr<void> after() {}
  FutureOr<S> reduce(S state);

  /// if you want to tie this action to a specific store
  /// by creating an instance will apply this action.
  /// if you do not override this store. any store with same generic can
  /// apply this action by calling store(Action());
  Store<S>? get store => null;
  @override
  String toString() => runtimeType.toString();
}

abstract class Middleware<S> {
  Future<void> apply(Store<S> store, Action<S> act, NextDispatcher<S> next);
}

typedef NextDispatcher<S> = Future<void> Function(Action<S> act);

class Token {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

class Store<S> {
  final S initialState;
  final List<Middleware<S>> middlewares;
  final Persistence<S> persistence;
  final Spark<Status> statusRM = Sparkle(Status.initial);

  Status status([Status? _status]) {
    if (_status != null) statusRM.state = _status;
    return statusRM.state;
  }

  bool get loading => status() == Status.loading;

  final Spark<String> errorRM = Sparkle('');
  String error([String? _error]) {
    if (_error != null) errorRM.state = _error;
    return errorRM.state;
  }

  late final Spark<S> stateRM = Sparkle(initialState);
  S _state([S? _state]) {
    if (_state != null) stateRM.state = _state;
    return stateRM.state;
  }

  S call([Action<S>? action]) {
    if (action != null) {
      _apply(action);
    }
    return _state();
  }

  Store(
    this.initialState, {
    this.middlewares = const [],
    required this.persistence,
  }) {
    final status = persistence.persistent ? 'enabled' : 'disabled';
    final type = switch (S) {
      Map => 'freezed',
      String => 'data class',
      _ => 'unknown',
    };
    log('serialization: $status');
    log('type: $type');
    if (persistence.persistent) read();
  }

  Future<void> _apply(Action<S> action) async {
    _cancelPendingActions();
    _currentAction = action;
    await _applyMiddleware(action, 0);
  }

  Future<void> _applyMiddleware(Action<S> action, int index) async {
    if (index < middlewares.length) {
      await middlewares[index].apply(
        this,
        action,
        (nextAction) => _applyMiddleware(nextAction, index + 1),
      );
    } else {
      _processAct(action);
    }
  }

  Action<S>? _currentAction;

  void _cancelPendingActions() {
    _currentAction?.token.cancel();
  }

  void _processAct(Action<S> action) async {
    status(Status.loading);
    try {
      await action.before();
      final nstate = await action.reduce(_state());
      if (action.token.isCancelled) return;

      status(Status.success);
      _state(nstate);
      if (persistence.persistent) await persistence.write(_state());
    } catch (e) {
      if (action.token.isCancelled) return;

      status(Status.error);
      error(e.toString());
    } finally {
      if (!action.token.isCancelled) {
        await action.after();
      }
    }
  }

  void read() {
    status(Status.loading);
    try {
      final storedValue = persistence.read();
      if (storedValue == null) return;
      status(Status.success);
      _state(storedValue);
    } catch (e) {
      status(Status.error);
      error(e.toString());
    }
  }

  late final build = buildStore.build;
  late final buildStore = Build(status, _state, error);

  Future<void> teardown() async {
    _cancelPendingActions();
    await statusRM.close();
    await errorRM.close();
    await stateRM.close();
  }
}

class Build<S> {
  final Status Function([Status?]) status;
  final S Function([S?]) state;
  final String Function([String?]) error;
  Build(this.status, this.state, this.error);

  Widget build(
    Widget Function(S state) data, {
    Widget Function()? loading,
    Widget Function(String? error)? onError,
    Widget Function()? initial,
  }) {
    const indicator = CircularProgressIndicator();
    switch (status()) {
      case Status.initial:
        return initial?.call() ?? loading?.call() ?? indicator;
      case Status.loading:
        return loading?.call() ?? indicator;
      case Status.success:
        return data.call(state());
      case Status.error:
        return onError?.call(error()) ?? loading?.call() ?? indicator;
      default:
        return initial?.call() ?? indicator;
    }
  }
}

class Persistence<S> {
  final String key;
  final FromJson<S>? fromJson;
  final String Function(S)? toJson;
  late final File file;

  bool get persistent => fromJson != null && key.isNotEmpty;

  Persistence._({required this.key, this.fromJson, this.toJson}) {
    file = File('${appDir.path}/$key.json');
  }

  factory Persistence.freezed({
    required String key,
    required FromJson<S> fromJson,
  }) {
    return Persistence._(
      key: key,
      fromJson: fromJson,
      toJson: (state) => jsonEncode((state as dynamic).toJson()),
    );
  }

  factory Persistence.data({
    required String key,
    required FromJson<S> fromMap,
  }) {
    return Persistence._(
      key: key,
      fromJson: fromMap,
      toJson: (state) => (state as dynamic).toJson(),
    );
  }

  factory Persistence.bool({
    required String key,
  }) {
    return Persistence._(
      key: key,
      fromJson: (json) => jsonDecode(json['value']),
      toJson: (state) => jsonEncode({'value': state}),
    );
  }

  factory Persistence.string({
    required String key,
  }) {
    return Persistence._(
      key: key,
      fromJson: (json) => jsonDecode(json['value']),
      toJson: (state) => jsonEncode({'value': state}),
    );
  }

  factory Persistence.num({
    required String key,
  }) {
    return Persistence._(
      key: key,
      fromJson: (json) => jsonDecode(json['value']),
      toJson: (state) => jsonEncode({'value': state}),
    );
  }

  factory Persistence.int({
    required String key,
  }) {
    return Persistence._(
      key: key,
      fromJson: (json) => jsonDecode(json['value']),
      toJson: (state) => jsonEncode({'value': state}),
    );
  }

  factory Persistence.double({
    required String key,
  }) {
    return Persistence._(
      key: key,
      fromJson: (json) => jsonDecode(json['value']),
      toJson: (state) => jsonEncode({'value': state}),
    );
  }

  factory Persistence.custom({
    required String key,
    required FromJson<S>? fromJson,
  }) {
    return Persistence._(
      key: key,
      fromJson: fromJson,
      toJson: (state) => jsonEncode(state),
    );
  }

  factory Persistence.list({
    required String key,
    required ListFromJson<S> fromJson,
    required ListToJson<S> toJson,
  }) {
    return Persistence._(
      key: key,
      fromJson: (json) => fromJson(json as List<dynamic>),
      toJson: (state) => jsonEncode(toJson(state)),
    );
  }

  S? read() {
    try {
      if (file.existsSync()) {
        return fromJson?.call(
          jsonDecode(
            file.readAsStringSync(),
          ),
        );
      }
    } catch (e) {
      log('Error reading from file: $e');
    }
    return null;
  }

  Future<void> write(S state) async {
    try {
      final jsonString = toJson?.call(state) ?? state.toString();
      await file.writeAsString(jsonString);
    } catch (e) {
      log('Error writing to file: $e');
    }
  }
}

enum Status { initial, loading, success, error }
