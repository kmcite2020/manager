// ignore_for_file: unused_field

library manager;

/// GLOBAL SETTINGS
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager/state_manager/ui/widgets.dart';

import 'simple.dart';

/// Event State Management -> Just like Bloc package
class Manager<E, T> extends Simple<T> {
  T initialBase;
  Manager(this.initialBase) : super(() => initialBase);
  final handlers = <Handler>[];
  void on<E>(
    HandlerFunction<E, T> handlerFunction,
  ) {
    final registered = handlers.any((handler) => handler.type == E);
    assert(
      !registered,
      'on<$E> was called multiple times.',
    );
    handlers.add(
      Handler(
        isType: (e) => e is E,
        type: E,
        function: handlerFunction,
      ),
    );
    print('${E} registered');
  }

  void add(E event) {
    final index = handlers.indexWhere((e) => e.isType(event));
    final eventType = event.runtimeType;
    assert(
      index != -1,
      'on<$eventType>(...) must be called before add($eventType)',
    );

    final fn = handlers[index].function;
    final emitter = Emitter<T>(
      (newState) => state = newState,
    );

    final result = fn(event, emitter) as FutureOr<void>;
    if (result is Future) {
      result.then(
        (_) => emitter._disable(),
      );
    } else {
      emitter._disable();
    }
  }

  @visibleForTesting
  set state(T newState) => value = newState;
  Widget build(Widget Function(T state) builder) => ManagerUI(
        builder: builder,
        manager: this,
      );
}

typedef HandlerFunction<E, State> = FutureOr<void> Function(
  E event,
  Emitter<State> emit,
);

class Handler {
  const Handler({
    required this.isType,
    required this.type,
    required this.function,
  });
  final bool Function(dynamic value) isType;
  final Type type;
  final Function function;
}

class Emitter<S> {
  Emitter(this._updater);
  final void Function(S newState) _updater;

  bool _enabled = true;

  void call(S newState) {
    assert(
      _enabled,
      '''\n\n
emit was called after an event handler completed normally.
This is usually due to an unawaited future in an event handler.
  **BAD**
  on<Event>((event, emit) {
    future.whenComplete(() => emit(...));
  });
  **GOOD**
  on<Event>((event, emit) async {
    await future.whenComplete(() => emit(...));
  });
''',
    );
    _updater(newState);
  }

  void _disable() {
    _enabled = false;
  }
}
