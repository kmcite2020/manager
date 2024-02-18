import '../../manager.dart';

class Simple<T> {
  T get state => rm();
  T call([T? newState]) => rm.call(newState);
  set state(T value) {
    rm.call(value);
  }

  late final RM<T> rm;
  Simple(T _state) {
    rm = RM(() => _state);
  }
}

final simpleRM = Simple(0);
