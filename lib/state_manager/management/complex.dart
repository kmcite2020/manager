import 'dart:async';

import 'package:flutter/material.dart';
import '../../manager.dart';

typedef Bloc<Event, State> = Complex<Event, State>;

abstract class Complex<Event, State> extends RM<State> {
  Complex(
    State value, {
    Persistor<State>? persistor,
  }) : super.create(() => value, persistor: persistor);
  final _handlers = <Handler>[];
  void on<Event>(
    EventRegistrar<Event, State> handlerFunction,
  ) {
    final registered = _handlers.any((handler) => handler.$2 == Event);
    assert(
      !registered,
      'on<$Event> was called multiple times.',
    );
    _handlers.add(
      (
        (e) => e is Event,
        Event,
        handlerFunction,
      ),
    );
    print('${Event} registered');
  }

  void add(Event event) {
    final index = _handlers.indexWhere((e) => e.$1(event));
    _handlers[index].$3(event, ((newState) => state = newState))
        as FutureOr<void>;
  }

  @visibleForTesting
  @override
  State call([State? t]) => super(t);

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
