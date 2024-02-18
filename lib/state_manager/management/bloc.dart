import 'dart:async';

import '../../manager.dart';

typedef Emitter<T> = void Function(T newState);
typedef TypeChecker = bool Function(dynamic);
typedef EventRegistrar<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> updater,
);

class Handler {
  final TypeChecker isType;
  final Type type;
  final Function function;

  Handler({
    required this.isType,
    required this.type,
    required this.function,
  });
  @override
  String toString() => 'isType:$isType, type:$type, function:$function';
}

abstract class Bloc<Event, State> {
  Persistor<State>? get persistor => null;
  State get initialState;
  final _handlers = <Handler>[];
  late final RM<State> rm = RM(
    () => initialState,
    persistor: persistor,
  );
  State call([Event? event]) {
    if (event != null) {
      final index = _handlers.indexWhere((e) => e.isType(event));
      _handlers[index].function(event, ((newState) => state = newState))
          as FutureOr<void>;
      print("${event.runtimeType} called");
    }
    return rm();
  }

  void register<Event>(
    EventRegistrar<Event, State> handlerFunction,
  ) {
    final registered = _handlers.any((handler) => handler.type == Event);
    assert(
      !registered,
      'register<$Event> was called multiple times.',
    );
    _handlers.add(
      Handler(
        isType: (e) => e is Event,
        type: Event,
        function: handlerFunction,
      ),
    );
    print('${Event} registered.');
  }

  State get state => call();
  @visibleForTesting
  set state(State newState) => rm(newState);
}
