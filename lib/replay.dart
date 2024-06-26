part of 'manager.dart';

///////////////////
/// REPLAY-BLOC ///
///////////////////

/// {@template replay_event}
/// Base event class for all [ReplayBloc] events.
/// {@endtemplate}
abstract class ReplayEvent {
  /// {@macro replay_event}
  const ReplayEvent();
}

/// Notifies a [ReplayBloc] of a Redo.
class _Redo extends ReplayEvent {
  @override
  String toString() => 'Redo';
}

/// Notifies a [ReplayBloc] of an Undo.
class _Undo extends ReplayEvent {
  @override
  String toString() => 'Undo';
}

/// {@template replay_bloc}
/// A specialized [Bloc] which supports `undo` and `redo` operations.
///
/// [ReplayBloc] accepts an optional `limit` which determines
/// the max size of the history.
///
/// A custom [ReplayBloc] can be created by extending [ReplayBloc].
///
/// ```dart
/// abstract class CounterEvent {}
/// class CounterIncrementPressed extends CounterEvent {}
///
/// class CounterBloc extends ReplayBloc<CounterEvent, int> {
///   CounterBloc() : super(0) {
///     on<CounterIncrementPressed>((event, emit) => emit(state + 1));
///   }
/// }
/// ```
///
/// Then the built-in `undo` and `redo` operations can be used.
///
/// ```dart
/// final bloc = CounterBloc();
///
/// bloc.add(CounterIncrementPressed());
///
/// bloc.undo();
///
/// bloc.redo();
/// ```
///
/// The undo/redo history can be destroyed at any time by calling `clear`.
///
/// See also:
///
/// * [Bloc] for information about the [ReplayBloc] superclass.
///
/// {@endtemplate}
abstract class ReplayBloc<Event extends ReplayEvent, State>
    extends Bloc<Event, State> with ReplayBlocMixin<Event, State> {
  /// {@macro replay_bloc}
  ReplayBloc(State state, {int? limit}) : super(state) {
    if (limit != null) {
      this.limit = limit;
    }
  }
}

/// A mixin which enables `undo` and `redo` operations
/// for [Bloc] classes.
mixin ReplayBlocMixin<Event extends ReplayEvent, State> on Bloc<Event, State> {
  late final _changeStack = _ChangeStack<State>(shouldReplay: shouldReplay);

  BlocObserver get _observer => Bloc.observer;

  /// Sets the internal `undo`/`redo` size limit.
  /// By default there is no limit.
  set limit(int limit) => _changeStack.limit = limit;

  @override
  // ignore: must_call_super
  void onTransition(covariant Transition<ReplayEvent, State> transition) {
    // ignore: invalid_use_of_protected_member
    _observer.onTransition(this, transition);
  }

  @override
  // ignore: must_call_super
  void onEvent(covariant ReplayEvent event) {
    // ignore: invalid_use_of_protected_member
    _observer.onEvent(this, event);
  }

  @override
  void emit(State state) {
    _changeStack.add(
      _Change<State>(
        this.state,
        state,
        () {
          final event = _Redo();
          onEvent(event);
          onTransition(
            Transition(
              currentState: this.state,
              event: event,
              nextState: state,
            ),
          );
          // ignore: invalid_use_of_visible_for_testing_member
          super.emit(state);
        },
        (val) {
          final event = _Undo();
          onEvent(event);
          onTransition(
            Transition(
              currentState: this.state,
              event: event,
              nextState: val,
            ),
          );
          // ignore: invalid_use_of_visible_for_testing_member
          super.emit(val);
        },
      ),
    );
    // ignore: invalid_use_of_visible_for_testing_member
    super.emit(state);
  }

  /// Undo the last change.
  void undo() => _changeStack.undo();

  /// Redo the previous change.
  void redo() => _changeStack.redo();

  /// Checks whether the undo/redo stack is empty.
  bool get canUndo => _changeStack.canUndo;

  /// Checks wether the undo/redo stack is at the current change.
  bool get canRedo => _changeStack.canRedo;

  /// Clear undo/redo history.
  void clearHistory() => _changeStack.clear();

  /// Checks whether the given state should be replayed from the undo/redo stack.
  ///
  /// This is called at the time the state is being restored.
  /// By default [shouldReplay] always returns `true`.
  bool shouldReplay(State state) => true;
}

/// {@template replay_cubit}
/// A specialized [Cubit] which supports `undo` and `redo` operations.
///
/// [ReplayCubit] accepts an optional `limit` which determines
/// the max size of the history.
///
/// A custom [ReplayCubit] can be created by extending [ReplayCubit].
///
/// ```dart
/// class CounterCubit extends ReplayCubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
/// }
/// ```
///
/// Then the built-in `undo` and `redo` operations can be used.
///
/// ```dart
/// final cubit = CounterCubit();
///
/// cubit.increment();
/// print(cubit.state); // 1
///
/// cubit.undo();
/// print(cubit.state); // 0
///
/// cubit.redo();
/// print(cubit.state); // 1
/// ```
///
/// The undo/redo history can be destroyed at any time by calling `clear`.
///
/// See also:
///
/// * [Cubit] for information about the [ReplayCubit] superclass.
///
/// {@endtemplate}
abstract class ReplayCubit<State> extends Cubit<State>
    with ReplayCubitMixin<State> {
  /// {@macro replay_cubit}
  ReplayCubit(State state, {int? limit}) : super(state) {
    if (limit != null) {
      this.limit = limit;
    }
  }
}

/// A mixin which enables `undo` and `redo` operations
/// for [Cubit] classes.
mixin ReplayCubitMixin<State> on Cubit<State> {
  late final _changeStack = _ChangeStack<State>(shouldReplay: shouldReplay);

  /// Sets the internal `undo`/`redo` size limit.
  /// By default there is no limit.
  set limit(int limit) => _changeStack.limit = limit;

  @override
  void emit(State state) {
    _changeStack.add(
      _Change<State>(
        this.state,
        state,
        () => super.emit(state),
        (val) => super.emit(val),
      ),
    );
    super.emit(state);
  }

  /// Undo the last change.
  void undo() => _changeStack.undo();

  /// Redo the previous change.
  void redo() => _changeStack.redo();

  /// Checks whether the undo/redo stack is empty.
  bool get canUndo => _changeStack.canUndo;

  /// Checks whether the undo/redo stack is at the current change.
  bool get canRedo => _changeStack.canRedo;

  /// Clear undo/redo history.
  void clearHistory() => _changeStack.clear();

  /// Checks whether the given state should be replayed from the undo/redo stack.
  ///
  /// This is called at the time the state is being restored.
  /// By default [shouldReplay] always returns `true`.
  bool shouldReplay(State state) => true;
}

typedef _Predicate<T> = bool Function(T);

class _ChangeStack<T> {
  _ChangeStack({required _Predicate<T> shouldReplay, this.limit})
      : _shouldReplay = shouldReplay;

  final Queue<_Change<T>> _history = ListQueue();
  final Queue<_Change<T>> _redos = ListQueue();
  final _Predicate<T> _shouldReplay;

  int? limit;

  bool get canRedo => _redos.any((c) => _shouldReplay(c._newValue));
  bool get canUndo => _history.any((c) => _shouldReplay(c._oldValue));

  void add(_Change<T> change) {
    if (limit != null && limit == 0) return;

    _history.addLast(change);
    _redos.clear();

    if (limit != null && _history.length > limit!) {
      if (limit! > 0) _history.removeFirst();
    }
  }

  void clear() {
    _history.clear();
    _redos.clear();
  }

  void redo() {
    if (canRedo) {
      final change = _redos.removeFirst();
      _history.addLast(change);
      return _shouldReplay(change._newValue) ? change.execute() : redo();
    }
  }

  void undo() {
    if (canUndo) {
      final change = _history.removeLast();
      _redos.addFirst(change);
      return _shouldReplay(change._oldValue) ? change.undo() : undo();
    }
  }
}

class _Change<T> {
  _Change(
    this._oldValue,
    this._newValue,
    this._execute,
    this._undo,
  );

  final T _oldValue;
  final T _newValue;
  final void Function() _execute;
  final void Function(T oldValue) _undo;

  void execute() => _execute();
  void undo() => _undo(_oldValue);
}

///////////////////
/// CONCURRENCY ///
///////////////////

/// Process events concurrently.
///
/// **Note**: there may be event handler overlap and state changes will occur
/// as soon as they are emitted. This means that states may be emitted in
/// an order that does not match the order in which the corresponding events
/// were added.
EventTransformer<Event> concurrent<Event>() {
  return (events, mapper) => events.concurrentAsyncExpand(mapper);
}

/// Process only one event and ignore (drop) any new events
/// until the current event is done.
///
/// **Note**: dropped events never trigger the event handler.
EventTransformer<Event> droppable<Event>() {
  return (events, mapper) {
    return events.transform(_ExhaustMapStreamTransformer(mapper));
  };
}

class _ExhaustMapStreamTransformer<T> extends StreamTransformerBase<T, T> {
  _ExhaustMapStreamTransformer(this.mapper);

  final EventMapper<T> mapper;

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamSubscription<T> subscription;
    StreamSubscription<T>? mappedSubscription;

    final controller = StreamController<T>(
      onCancel: () async {
        await mappedSubscription?.cancel();
        return subscription.cancel();
      },
      sync: true,
    );

    subscription = stream.listen(
      (data) {
        if (mappedSubscription != null) return;
        final Stream<T> mappedStream;

        mappedStream = mapper(data);
        mappedSubscription = mappedStream.listen(
          controller.add,
          onError: controller.addError,
          onDone: () => mappedSubscription = null,
        );
      },
      onError: controller.addError,
      onDone: () => mappedSubscription ?? controller.close(),
    );

    return controller.stream;
  }
}

/// Process only one event by cancelling any pending events and
/// processing the new event immediately.
///
/// Avoid using [restartable] if you expect an event to have
/// immediate results -- it should only be used with asynchronous APIs.
///
/// **Note**: there is no event handler overlap and any currently running tasks
/// will be aborted if a new event is added before a prior one completes.
EventTransformer<Event> restartable<Event>() {
  return (events, mapper) => events.switchMap(mapper);
}

/// Process events one at a time by maintaining a queue of added events
/// and processing the events sequentially.
///
/// **Note**: there is no event handler overlap and every event is guaranteed
/// to be handled in the order it was received.
EventTransformer<Event> sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}
