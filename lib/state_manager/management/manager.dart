import '../../manager.dart';

typedef Notifier<State> = Cubit<State>;

abstract class Cubit<State> extends RM<State> {
  Cubit(State state, {Persistor<State>? persistor})
      : super.create(
          () => state,
          persistor: persistor,
        );
  State get state => super();
  set state(State newState) => super(newState);
}
