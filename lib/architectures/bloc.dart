// import 'package:manager/manager.dart';
// import 'spark.dart';

// /// PARTS OF BLOC ARCHITECTURE
// /// 1. STATEs
// /// states are core parts of a bloc architecture
// /// bloc is there to manage states simple
// /// states are objects that are used in application to visualize
// /// the app.
// ///
// /// 2. BLOC
// /// 3. EVENTs
// ///
// /// SURFACE API
// /// There are two ways to create blocs
// /// 1. implementing a Bloc<E,T> interface and creating an instance
// /// 2. creating an instance of ConcreteBloc<E,T>
// ///
// /// State & Event updates should happen through its callable method.
// /// T call([E? event])
// /// if event is passed this call will add event to Bloc else it will
// /// return current state of the Bloc.
// ///
// /// If a reactive value is changed it will notify its list of listeners
// /// if another computed which depends on another and is mutated. its
// /// dependents will be notified.

// void bloc(Widget app) => runApp(app);

import 'spark.dart';

abstract class Bloc<Event, State> extends Spark<State> {
  final handlers = <Type, void Function(Event event)>{};

  State call([Event? event]) {
    if (event != null && handlers.containsKey(event.runtimeType)) {
      handlers[event.runtimeType]!(event);
    }
    return state;
  }

  @deprecated
  void on<E extends Event>(
    void Function(E event, void Function(State) emit) handler,
  ) {
    handlers[E] = (event) {
      handler(
        event as E,
        (newState) {
          state = newState;
        },
      );
    };
  }

  register<E extends Event>(
    void Function(E Function([State? newState]) modifier) handler,
  ) {
    handlers[E] = (event) {
      handler(
        ([newState]) {
          if (newState != null) {
            state = newState;
          } else {}
          return event as E;
        },
      );
    };
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

abstract class Cubit<T> extends Bloc<T, T> {
  Cubit(this.initialState) {
    register<T>((modifier) => modifier(modifier()));
  }

  @override
  final T initialState;
}
