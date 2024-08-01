import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'package:manager/manager.dart';
part 'persistent_spark.dart';
part 'ui_helpers.dart';
part 'extensions.dart';
part 'ui.dart';

typedef Middleware<S>(Store<S> store, action, NextDispatcher next);

class Store<S> {
  Reducer<S> reducer;
  late final StreamController<S> _changeController = StreamController.broadcast(sync: sync);
  late S initialState;
  late final List<NextDispatcher> _dispatchers;
  final bool sync;
  final bool distinct;
  Store(
    this.reducer, {
    required this.initialState,
    List<Middleware<S>> middlewares = const [],
    this.sync = false,
    this.distinct = false,
  }) {
    _dispatchers = dispatchers(
      middlewares,
      dispatcher(distinct),
    );
  }
  S get state => initialState;
  Stream<S> get onChange => _changeController.stream;
  NextDispatcher dispatcher(bool distinct) {
    return (action) {
      final state = reducer(initialState, action);
      if (distinct && state == initialState) return;
      initialState = state;
      _changeController.add(state);
    };
  }

  List<NextDispatcher> dispatchers(
    List<Middleware<S>> middlewares,
    NextDispatcher dispatcher,
  ) {
    final dispatchers = <NextDispatcher>[]..add(dispatcher);
    for (var nextMiddleware in middlewares.reversed) {
      final next = dispatchers.last;
      dispatchers.add(
        (dynamic action) => nextMiddleware(this, action, next),
      );
    }
    return dispatchers.reversed.toList();
  }

  void dispatch(action) => _dispatchers[0](action);
  Future teardown() async => _changeController.close();
}
