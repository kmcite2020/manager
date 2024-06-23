part of 'manager.dart';

abstract class Act<T> {
  const Act();
  T reduce(T state);
}

abstract class Middleware<T> {
  Future<void> call(Store<T> store, Act<T> action, NextDispatcher next);
}

typedef NextDispatcher<T> = Future<void> Function(Act<T> action);

class Store<T> extends Spark<T> {
  @override
  final T initialState;
  final List<Middleware<T>> middlewares;

  Store(
    this.initialState, {
    this.middlewares = const <Middleware<T>>[],
  });

  void dispatch(Act<T> act) {
    applyMiddlewares(
      act,
      (act) async => emit(act.reduce(state)),
    );
  }

  void applyMiddlewares(Act<T> act, NextDispatcher next) {
    int index = -1;

    Future<void> dispatchNext(Act act) async {
      index++;
      if (index < middlewares.length) {
        await middlewares[index].call(this, act as Act<T>, dispatchNext);
      } else {
        await next(act);
      }
    }

    dispatchNext(act);
  }
}
