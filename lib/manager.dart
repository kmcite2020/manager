// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// import 'dart:convert';

// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:package_info_plus/package_info_plus.dart';

export 'package:manager/manager.dart';
part 'persistent_spark.dart';
part 'ui_helpers.dart';
part 'extensions.dart';
part 'ui.dart';

typedef Apply<S> = void Function(Act<S>);

abstract class Act<S> {
  void before() {}
  void after() {}
  S reduce(S state);
}

class Sparkle<S> extends Spark<S> {
  final initialState;
  Sparkle(this.initialState);
  S call([S? newState]) {
    if (newState != null) {
      _state = newState;
    }
    return _state;
  }
}

abstract class Spark<S> {
  S get initialState;
  late S _state = initialState;
  late final _changeController = StreamController<S>.broadcast();

  Stream<S> get stream => _changeController.stream;

  S get state => _state;
  Future teardown() => _changeController.close();
}

class Store<S> extends Spark<S> {
  S get state => _state;
  final initialState;
  late final _changeController = StreamController<S>.broadcast(sync: sync);
  final bool sync;
  final bool distinct;
  final List<Middleware<S>> middlewares;
  void apply(Act<S> action) {
    applyMiddlewares(action, 0);
    final state = action.reduce(_state);
    if (distinct && state == _state) return;
    _state = state;
    _changeController.add(state);
  }

  void applyMiddlewares(Act<S> act, int index) {
    switch (index < middlewares.length) {
      case true:
        middlewares[index].apply(
          this,
          act,
          (nextAction) => applyMiddlewares(nextAction, index + 1),
        );
      case false:
    }
  }

  Store(
    this.initialState, {
    this.sync = false,
    this.distinct = false,
    this.middlewares = const [],
  });
}

abstract class Middleware<S> {
  void apply(Store<S> store, Act<S> act, NextDispatcher<S> next);
}

typedef void NextDispatcher<S>(Act<S> act);


// class Store<S> {
//   Reducer<S> reducer;
//   late final StreamController<S> _changeController =
//       StreamController.broadcast(sync: sync);
//   late S initialState;
//   late final List<NextDispatcher> _dispatchers;
//   final bool sync;
//   final bool distinct;
//   Store(
//     this.reducer, {
//     required this.initialState,
//     List<Middleware<S>> middlewares = const [],
//     this.sync = false,
//     this.distinct = false,
//   }) {
//     _dispatchers = dispatchers(
//       middlewares,
//       dispatcher(distinct),
//     );
//   }
//   S get state => initialState;
//   Stream<S> get onChange => _changeController.stream;
//   NextDispatcher dispatcher(bool distinct) {
//     return (action) {
//       final state = reducer(initialState, action);
//       if (distinct && state == initialState) return;
//       initialState = state;
//       _changeController.add(state);
//     };
//   }

//   List<NextDispatcher> dispatchers(
//     List<Middleware<S>> middlewares,
//     NextDispatcher dispatcher,
//   ) {
//     final dispatchers = <NextDispatcher>[]..add(dispatcher);
//     for (final nextMiddleware in middlewares.reversed) {
//       final next = dispatchers.last;
//       dispatchers.add(
//         (dynamic action) => nextMiddleware(this, action, next),
//       );
//     }
//     return dispatchers.reversed.toList();
//   }

//   void dispatch(action) => _dispatchers[0](action);
//   Future teardown() async => _changeController.close();
// }
