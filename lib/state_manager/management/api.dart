abstract class StateGetter<T> {
  T get state;
}

abstract class InitialStateGetter<T> {
  T? get initialState;
}

abstract class StateSetter<T> {
  set state(T newState);
}

abstract class StateCallable<T> {
  T call([T? newState]);
}
