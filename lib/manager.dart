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

typedef Apply<S> = void Function(Act<S> act);
typedef NextDispatcher<S> = void Function(Act<S> act);

abstract class Act<S> {
  void before() {}
  void after() {}
  S reduce(S state);
}

abstract class Middleware<S> {
  void apply(Store<S> store, Act<S> act, NextDispatcher<S> next);
}

class Store<S> {
  S _state;
  final bool sync;
  final bool distinct;
  final List<Middleware<S>> middlewares;
  late final StreamController<S> _changeController = StreamController<S>.broadcast(sync: sync);

  Store(
    this._state, {
    this.sync = false,
    this.distinct = false,
    this.middlewares = const [],
  });

  Stream<S> get stream => _changeController.stream;
  S get state => _state;

  void apply(Act<S> action) {
    _applyMiddleware(action, 0);
  }

  void _applyMiddleware(Act<S> action, int index) {
    if (index < middlewares.length) {
      middlewares[index].apply(
        this,
        action,
        (nextAction) => _applyMiddleware(nextAction, index + 1),
      );
    } else {
      processAct(action);
    }
  }

  void processAct(Act<S> action) {
    action.before();
    final newState = action.reduce(_state);
    if (!distinct || newState != _state) {
      _state = newState;
      _changeController.add(_state);
    }
    action.after();
  }

  Future<void> teardown() => _changeController.close();
}


// 
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
