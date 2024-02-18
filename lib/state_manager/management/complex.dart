import 'dart:async';

import 'package:flutter/material.dart';
import '../../manager.dart';

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

class Bloc<E, S> {
  Bloc(S state, {Persistor<S>? persistor}) {
    rm = RM(state, persistor: persistor);
  }
  final _handlers = <Handler>[];
  late final RM<S> rm;
  S call([E? event]) {
    if (event != null) {
      final index = _handlers.indexWhere((e) => e.$1(event));
      _handlers[index].$3(event, ((newState) => state = newState))
          as FutureOr<void>;
      print("${event.runtimeType} called");
    }
    return rm();
  }

  void register<E>(
    EventRegistrar<E, S> handlerFunction,
  ) {
    final registered = _handlers.any((handler) => handler.$2 == E);
    assert(
      !registered,
      'register<$E> was called multiple times.',
    );
    _handlers.add(
      (
        (e) => e is E,
        E,
        handlerFunction,
      ),
    );
    print('${E} registered');
  }

  S get state => call();
  @visibleForTesting
  set state(S newState) => rm(newState);
}
