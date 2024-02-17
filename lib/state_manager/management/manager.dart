import '../../manager.dart';

typedef Notifier<State> = Manager<State>;
typedef Cubit<State> = Manager<State>;

abstract class Manager<State> extends RM<State> {
  Manager(State state, {Persistor<State>? persistor})
      : super.create(
          () => state,
          persistor: persistor,
        );
  State get state => super();
  set state(State newState) => super(newState);
}
