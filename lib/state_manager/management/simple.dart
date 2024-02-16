import 'package:states_rebuilder/scr/state_management/rm.dart';

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

class SimpleManager<T> extends ReactiveModelImp<T>
    implements
        InitialStateGetter<T>,
        StateCallable<T>,
        StateSetter<T>,
        StateGetter<T> {
  final T Function() creator;
  SimpleManager(this.creator)
      : super(
            creator: creator,
            initialState: null,
            autoDisposeWhenNotUsed: false,
            stateInterceptorGlobal: null);

  @override
  T? get initialState => super.initialState;

  @override
  T get state => super.state;

  @override
  T call([T? newState]) {
    if (newState != null) state = newState;
    return state;
  }

  @override
  set state(T newState) {
    super.state = newState;
  }
}

// typedef Creator<T> = T Function();

// /// GLOBAL STATE MANAGEMENT
// class Simple<T> extends Readonly<T> {
//   T? _base;
//   Creator<T> creator;
//   Simple(this.creator) {
//     recreate();
//   }
//   void recreate() {
//     _base = creator();
//   }

//   void setState(T state) => notify(() => _base = state);

//   void notify(void Function() modifier) {
//     WidgetsBinding.instance.addPostFrameCallback(
//       (timeStamp) {
//         for (final setState in setStates) {
//           setState(modifier);
//         }
//       },
//     );
//   }

//   set data(T newData) => setState(newData);
//   set state(T newState) => setState(newState);
//   set value(T newValue) => setState(newValue);

//   T call([T? newCall]) {
//     if (newCall != null) setState(newCall);
//     return _base!;
//   }

//   @override
//   T get data => _base!;

//   @override
//   T get state => _base!;

//   @override
//   T get value => _base!;
//   Widget build(Widget Function(T state) builder) => SimpleUI(
//         builder: builder,
//         simple: this,
//       );
// }
