import '../../manager.dart';

abstract class Cubit<T> {
  late final RM<T> rm = RM(
    () => initialState,
    persistor: persistor,
  );
  Persistor<T>? get persistor => null;
  T get initialState;
  T get state => call();
  set state(T newState) => call(newState);
  T call([T? newState]) => rm(newState);
}
