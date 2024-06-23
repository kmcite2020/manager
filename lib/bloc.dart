part of 'manager.dart';

abstract class Bloc<Event, State> extends Spark<State> {
  @override
  State get initialState;

  final _handlers = <Handler>[];
  @visibleForTesting
  void on<E extends Event>(
    HandlerFunction<E, State> function,
  ) {
    final registered = _handlers.any((handler) => handler.type == E);
    assert(
      !registered,
      'on<$E> was called multiple times.', // coverage:ignore-line
    );
    _handlers.add(
      Handler(
        isType: (e) => e is E,
        type: E,
        function: function,
      ),
    );
  }

  @visibleForTesting
  void add(Event event) {
    final index = _handlers.indexWhere((e) => e.isType(event));
    final eventType = event.runtimeType;
    assert(
      index != -1,
      'on<$eventType>(...) must be called before add($eventType)',
    );

    final function = _handlers[index].function;
    final emitter = Emitter<State>(
      (newState) => state = newState,
    );

    final result = function(event, state, emitter) as FutureOr<void>;

    if (result is Future) {
      result.then(
        (_) => emitter._disable(),
      );
    } else {
      emitter._disable();
    }
  }

  State call([Event? toCall]) {
    if (toCall != null) add(toCall);
    return state;
  }

  @visibleForTesting
  @override
  set state(State newState) => super.state = newState;
}

typedef HandlerFunction<Event, State> = FutureOr<void> Function(
  Event event,
  State state,
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

class Emitter<State> {
  Emitter(this._updater);
  final void Function(State newState) _updater;

  bool _enabled = true;

  void call(State newState) {
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
