// ignore_for_file: unused_field

library manager;

/// GLOBAL SETTINGS
import 'dart:async';

import 'package:flutter/material.dart';
import '../../manager.dart';

abstract class Complex<Event, State> extends RM<State> {
  Complex(State value) : super.create(() => value);
  final handlers = <Handler>[];
  void on<Event>(
    EventRegistrar<Event, State> handlerFunction,
  ) {
    final registered = handlers.any((handler) => handler.$2 == Event);
    assert(
      !registered,
      'on<$Event> was called multiple times.',
    );
    handlers.add(
      (
        (e) => e is Event,
        Event,
        handlerFunction,
      ),
    );
    print('${Event} registered');
  }

  void add(Event event) {
    final index = handlers.indexWhere((e) => e.$1(event));
    handlers[index].$3(event, ((newState) => state = newState))
        as FutureOr<void>;
  }

  State get state => call();
  @visibleForTesting
  set state(State newState) => call(newState);
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
