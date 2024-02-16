// ignore_for_file: unused_field

library manager;

/// GLOBAL SETTINGS
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager/state_manager/ui/widgets.dart';
import 'simple.dart';

/// Event State Management -> Just like Bloc package
class Manager<E, T> extends SimpleManager<T> {
  T initialBase;
  Manager(this.initialBase) : super(() => initialBase);
  final handlers = <Handler>[];
  void on<E>(
    EventRegistrar<E, T> handlerFunction,
  ) {
    final registered = handlers.any((handler) => handler.$2 == E);
    assert(
      !registered,
      'on<$E> was called multiple times.',
    );
    handlers.add(
      (
        (e) => e is E,
        E,
        handlerFunction,
      ),
    );
    print('${E} registered');
  }

  void add(E event) {
    final index = handlers.indexWhere((e) => e.$1(event));
    handlers[index].$3(event, ((newState) => state = newState))
        as FutureOr<void>;
  }

  @visibleForTesting
  set state(T newState) => super.state = newState;
  Widget build(Widget Function(T state) builder) => ManagerUI(
        builder: builder,
        manager: this,
      );
}

typedef Emitter<T> = void Function(T newState);
typedef Handler = (
  bool Function(dynamic value) isType,
  Type type,
  Function function,
);
typedef EventRegistrar<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> setState,
);
