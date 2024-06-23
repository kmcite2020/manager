part of 'manager.dart';

class Simple<T> extends Spark<T> {
  Simple(this.initialState);
  @override
  final T initialState;
  T call([T? toCall]) {
    if (toCall != null) {
      state = toCall;
    }
    return state;
  }
}
