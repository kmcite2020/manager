// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
export 'package:manager/manager.dart';
part 'ui_helpers.dart';
part 'extensions.dart';
part 'ui.dart';

typedef T FromJson<T>(Map<String, dynamic> json);

abstract class Act<S> {
  void before() {}
  void after() {}
  S reduce(S state);
}

abstract class Middleware<S> {
  Future<void> apply(Store<S> store, Act<S> act, NextDispatcher<S> next);
}

typedef NextDispatcher<S> = Future<void> Function(Act<S> act);

late Box storage;

class Store<S> {
  static Future<void> init() async {
    await Hive.initFlutter();
    final app = await PackageInfo.fromPlatform();
    storage = await Hive.openBox('${app.appName}_${app.version}');
  }

  SnapState<S> _snapState;

  final bool sync;
  final List<Middleware<S>> middlewares;
  late final StreamController<SnapState<S>> _changeController =
      StreamController<SnapState<S>>.broadcast(sync: sync);
  final FromJson<S>? fromJson;
  static const _key = 'app_state';

  Store(
    S initialState, {
    this.sync = false,
    this.middlewares = const [],
    this.fromJson,
  }) : _snapState = SnapState(state: initialState) {
    final status = fromJson != null ? 'enabled' : 'disabled';
    final type = switch ((state as dynamic).toJson().runtimeType) {
      Map => 'freezed',
      String => 'data class',
      _ => 'unknown',
    };
    log('serialization: $status');
    log('type: $type');
    read();
  }

  Stream<S> get stream => _changeController.stream.map((snap) => snap.state);
  SnapState<S> get snap => _snapState;
  S get state => snap.state;
  bool get loading => _snapState.loading;

  void apply(Act<S> action) {
    _applyMiddleware(action, 0);
  }

  Future<void> _applyMiddleware(Act<S> action, int index) async {
    if (index < middlewares.length) {
      await middlewares[index]
          .apply(this, action, (nextAction) => _applyMiddleware(nextAction, index + 1));
    } else {
      _processAct(action);
    }
  }

  void _processAct(Act<S> action) {
    action.before();
    _setLoading(true);
    try {
      final newStateData = action.reduce(_snapState.state);
      _snapState = _snapState.copyWith(
        data: newStateData,
        status: SnapStatus.success,
        loading: false,
      );
      _changeController.add(_snapState);
      write();
    } catch (e) {
      _snapState = _snapState.copyWith(
        status: SnapStatus.error,
        error: e.toString(),
        loading: false,
      );
      _changeController.add(_snapState);
    }
    action.after();
  }

  void _setLoading(bool loading) {
    _changeController.add(_snapState.copyWith(loading: loading));
  }

  void read() {
    if (fromJson != null) {
      final storedValue = storage.get(_key);
      if (storedValue == null) return;

      final json = jsonDecode(storedValue);
      if (json == null) return;

      final state = fromJson?.call(json);
      if (state == null) return;

      _snapState = SnapState(
        state: state,
        status: SnapStatus.success,
      );
    }
  }

  Future<void> write() async {
    if (fromJson != null) {
      try {
        final jsonState = (_snapState.state as dynamic).toJson();
        final jsonString = switch (jsonState.runtimeType) {
          Map => jsonEncode(jsonState),
          String => jsonState,
          _ => throw FlutterError('Unexpected result of toJson()'),
        };
        await storage.put(_key, jsonString);
      } catch (e) {
        print('Error in write(): $e');
        rethrow;
      }
    }
  }

  Future<void> teardown() => _changeController.close();
}

enum SnapStatus { initial, loading, success, error }

class SnapState<S> {
  final S state;
  final SnapStatus status;
  final String? error;
  final bool loading;

  SnapState({
    required this.state,
    this.status = SnapStatus.initial,
    this.error,
    this.loading = false,
  });

  SnapState<S> copyWith({
    S? data,
    SnapStatus? status,
    String? error,
    bool? loading,
  }) {
    return SnapState<S>(
      state: data ?? this.state,
      status: status ?? this.status,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}
