import '../manager.dart';

// Store class definition
class Global<T> {
  late final stateRM = RM.inject(
    () => initialState,
    persist: key != null ? () => persisted(key!, fromJson) : null,
  ); // Reactive state
  final T initialState;
  final List<Middleware> globalMiddlewares;

  final String? key;
  final FutureOr<T> Function(Map<String, dynamic>)? fromJson;
  Global(
    this.initialState, {
    this.globalMiddlewares = const [],
    this.key,
    this.fromJson,
  });

  // Public method to trigger actions
  T call([Action<T>? act]) {
    if (act != null) {
      _applyAct(act);
    }
    return stateRM.state;
  }

  // Apply the action and pass it through middleware
  void _applyAct(Action<T> act) async {
    // Apply global middlewares first
    await _applyMiddlewares(globalMiddlewares, act);
    // Then apply the action itself to update state
    stateRM.state = await act.reduce(stateRM.state);
  }

  // Method to apply middleware
  Future<void> _applyMiddlewares(
      List<Middleware> middlewares, Action<T> action) async {
    final Set<Type> appliedActions = {};
    for (var middleware in middlewares) {
      await middleware.apply(this, action, appliedActions);
    }
  }

  // Selector to handle nested state
  Local<T, S> scoped<S>(
    S Function(T) selector,
    S Function(S, T) updater, {
    List<Middleware> scopedMiddlewares = const [],
    bool includeGlobalMiddlewares = true,
  }) {
    final combinedMiddlewares = includeGlobalMiddlewares
        ? (List<Middleware>.from(globalMiddlewares)..addAll(scopedMiddlewares))
        : scopedMiddlewares;

    return Local<T, S>(
      selector,
      updater,
      stateRM.state,
      combinedMiddlewares,
    );
  }
}

// Local class definition
class Local<T, S> extends Global<S> {
  late final Function onUpdate;

  Local(
    S Function(T) local,
    S Function(S, T) localUpdater,
    T state,
    List<Middleware> middlewares,
  ) : super(
          local(state),
          globalMiddlewares: middlewares,
        ) {
    onUpdate = (T newState) {
      stateRM.state = localUpdater(stateRM.state, newState);
    };
  }
}

// Action base class
abstract class Action<T> {
  FutureOr<T> reduce(T state);
}

// Middleware base class
abstract class Middleware<T> {
  Future<void> apply(
      Global<T> store, Action<T> action, Set<Type> appliedActions) async {
    // Prevent applying the same action more than once
    if (!appliedActions.contains(action.runtimeType)) {
      appliedActions.add(action.runtimeType);
      await perform(store, action);
    }
  }

  Future<void> perform(Global<T> store, Action<T> action);
}
