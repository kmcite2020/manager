import 'package:manager/manager.dart';

import 'spark.dart';

void bloc(Widget app) => runApp(app);

abstract class Bloc<Event, State> extends Spark<State> {
  final handlers = <Type, void Function(Event)>{};

  State call([Event? event]) {
    if (event != null && handlers.containsKey(event.runtimeType)) {
      handlers[event.runtimeType]!(event);
    }
    return state;
  }

  void on<E extends Event>(
      void Function(E event, void Function(State) emit) handler) {
    handlers[E] =
        (event) => handler(event as E, (newState) => state = newState);
  }
}

class ConcreteBloc<E, S> extends Bloc<E, S> {
  final initialState;

  ConcreteBloc(
    this.initialState, {
    required void configure(ConcreteBloc<E, S> bloc),
  }) {
    configure(this);
  }
}
