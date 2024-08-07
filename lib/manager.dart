import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'rm.dart';
export 'package:manager/manager.dart';
part 'extensions.dart';

Future<void> RUN(Widget app) => _init().then((_) => runApp(app));

late Box storage;

Future<void> _init() async {
  await Hive.initFlutter();
  final app = await PackageInfo.fromPlatform();
  storage = await Hive.openBox('${app.appName}_${app.version}');
}

typedef T FromJson<T>(Map<String, dynamic> json);

abstract class Action<S> {
  FutureOr<void> before() {}
  FutureOr<void> after() {}
  FutureOr<S> reduce(S state);
}

abstract class Middleware<S> {
  Future<void> apply(Store<S> store, Action<S> act, NextDispatcher<S> next);
}

typedef NextDispatcher<S> = Future<void> Function(Action<S> act);

class Store<S> {
  final S initialState;

  final List<Middleware<S>> middlewares;

  final String key; // for persistence -> empty mean no persistence
  final FromJson<S>? fromJson; // persistence
  bool get persistent => fromJson != null && key.isNotEmpty;

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
    this.fromJson,
    this.key = '',
  }) {
    final status = persistent ? 'enabled' : 'disabled';
    final type = switch ((_state() as dynamic).toJson().runtimeType) {
      Map => 'freezed',
      String => 'data class',
      _ => 'unknown',
    };
    log('serialization: $status');
    log('type: $type');
    if (persistent) read();
  }

  Future<void> _apply(Action<S> action) => _applyMiddleware(action, 0);

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

  void _processAct(Action<S> action) async {
    status(Status.loading);
    try {
      await action.before();
      final nstate = await action.reduce(_state());
      status(Status.success);
      _state(nstate);
      if (persistent) await write();
    } catch (e) {
      status(Status.error);
      error(e.toString());
    } finally {
      await action.after();
    }
  }

  void read() {
    status(Status.loading);
    try {
      final storedValue = storage.get(key);
      if (storedValue == null) return;

      final json = jsonDecode(storedValue);
      final nstate = fromJson?.call(json);
      if (nstate == null) return;
      status(Status.success);
      _state(nstate);
    } catch (e) {
      status(Status.error);
      error(e.toString());
    }
  }

  Future<void> write() async {
    try {
      final jsonState = (_state() as dynamic).toJson();
      final jsonString = switch (jsonState.runtimeType) {
        Map => jsonEncode(jsonState),
        String => jsonState,
        _ => throw FlutterError('Unexpected result of toJson()'),
      };
      await storage.put(key, jsonString);
    } catch (e) {
      status(Status.error);
      error(e.toString());
    }
  }

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
        return data.call(_state());
      case Status.error:
        return onError?.call(error()) ?? loading?.call() ?? indicator;
      default:
        return initial?.call() ?? indicator;
    }
  }

  Future<void> teardown() async {
    await statusRM.close();
    await errorRM.close();
    await stateRM.close();
  }
}

enum Status { initial, loading, success, error }
