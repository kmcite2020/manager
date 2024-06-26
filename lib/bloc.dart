part of 'manager.dart';

abstract class TopUI extends UI {
  const TopUI({super.key});

  ThemeData get theme;
  ThemeData get darkTheme;
  ThemeMode get themeMode;

  Widget homePage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homePage(context),
      themeMode: themeMode,
      theme: theme,
      darkTheme: darkTheme,
    );
  }
}

abstract class UI extends StatefulWidget {
  const UI({super.key});

  Widget build(BuildContext context);

  @override
  ExtendedState createState() => ExtendedState();
}

class ExtendedState extends State<UI> {
  ExtendedState() {
    _observer = Observer();
  }

  Observer? _observer;
  late StreamSubscription _subscription;
  bool _afterFirstLayout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      _afterFirstLayout = true;
    });
    _subscription = _observer!.listen(_rebuild);
  }

  @override
  void dispose() {
    _afterFirstLayout = false;
    _subscription.cancel();
    if (_observer?.canUpdate ?? false) {
      _observer?.close();
    }

    super.dispose();
  }

  void _rebuild(_) {
    if (_afterFirstLayout && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Observer.proxy;

    Observer.proxy = _observer;
    final result = widget.build(context);
    Observer.proxy = observer;
    return result;
  }
}

class Observer<T> {
  BlocBase<T?> subject = Spark(null);

  static Observer? proxy;

  final Map<BlocBase, List<StreamSubscription>> _subscriptions = {};
  Map<BlocBase, List<StreamSubscription>> get subscriptions => _subscriptions;

  bool get canUpdate => subscriptions.isNotEmpty;

  void addListener(BlocBase<T> spark) {
    if (!_subscriptions.containsKey(spark)) {
      final StreamSubscription subscription =
          spark.stream.listen(subject.controller.add);
      final listSubscriptions = _subscriptions[spark] ?? [];
      listSubscriptions.add(subscription);
      _subscriptions[spark] = listSubscriptions;
    }
  }

  StreamSubscription<T?> listen(void Function(T?) _) {
    return subject.stream.listen(_);
  }

  FutureOr<void> close() async {
    for (final e in _subscriptions.values) {
      for (final subs in e) {
        await subs.cancel();
      }
    }
    _subscriptions.clear();
    return subject.close();
  }
}

///////
///
///////

class Change<State> {
  const Change({required this.currentState, required this.nextState});
  final State currentState;
  final State nextState;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Change<State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState;

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Change { currentState: $currentState, nextState: $nextState }';
  }
}

class Transition<Event, State> extends Change<State> {
  const Transition({
    required State currentState,
    required this.event,
    required State nextState,
  }) : super(currentState: currentState, nextState: nextState);
  final Event event;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transition<Event, State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          event == other.event &&
          nextState == other.nextState;

  @override
  int get hashCode {
    return currentState.hashCode ^ event.hashCode ^ nextState.hashCode;
  }

  @override
  String toString() {
    return '''Transition { currentState: $currentState, event: $event, nextState: $nextState }''';
  }
}

class Spark<T> extends Cubit<T> {
  Spark(super.initialState);
}

abstract class Cubit<State> extends BlocBase<State> {
  Cubit(State initialState) : super(initialState);
  State call([State? newState]) {
    if (newState != null) {
      emit(newState);
    }
    return state;
  }
}

abstract class Emitter<State> {
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  });

  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  });
  bool get isDone;
  void call(State state);
}

class _Emitter<State> implements Emitter<State> {
  _Emitter(this._emit);

  final void Function(State state) _emit;
  final _completer = Completer<void>();
  final _disposables = <FutureOr<void> Function()>[];

  var _isCanceled = false;
  var _isCompleted = false;

  @override
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final completer = Completer<void>();
    final subscription = stream.listen(
      onData,
      onDone: completer.complete,
      onError: onError ?? completer.completeError,
      cancelOnError: onError == null,
    );
    _disposables.add(subscription.cancel);
    return Future.any([future, completer.future]).whenComplete(() {
      subscription.cancel();
      _disposables.remove(subscription.cancel);
    });
  }

  @override
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return onEach<T>(
      stream,
      onData: (data) => call(onData(data)),
      onError: onError != null
          ? (Object error, StackTrace stackTrace) {
              call(onError(error, stackTrace));
            }
          : null,
    );
  }

  @override
  void call(State state) {
    assert(
      !_isCompleted,
      '''


emit was called after an event handler completed normally.
This is usually due to an unawaited future in an event handler.
Please make sure to await all asynchronous operations with event handlers
and use emit.isDone after asynchronous operations before calling emit() to
ensure the event handler has not completed.

  **BAD**
  on<Event>((event, emit) {
    future.whenComplete(() => emit(...));
  });

  **GOOD**
  on<Event>((event, emit) async {
    await future.whenComplete(() => emit(...));
  });
''',
    );
    if (!_isCanceled) _emit(state);
  }

  @override
  bool get isDone => _isCanceled || _isCompleted;

  void cancel() {
    if (isDone) return;
    _isCanceled = true;
    _close();
  }

  void complete() {
    if (isDone) return;
    assert(
      _disposables.isEmpty,
      '''


An event handler completed but left pending subscriptions behind.
This is most likely due to an unawaited emit.forEach or emit.onEach. 
Please make sure to await all asynchronous operations within event handlers.

  **BAD**
  on<Event>((event, emit) {
    emit.forEach(...);
  });  
  
  **GOOD**
  on<Event>((event, emit) async {
    await emit.forEach(...);
  });

  **GOOD**
  on<Event>((event, emit) {
    return emit.forEach(...);
  });

  **GOOD**
  on<Event>((event, emit) => emit.forEach(...));

''',
    );
    _isCompleted = true;
    _close();
  }

  void _close() {
    for (final disposable in _disposables) {
      disposable.call();
    }
    _disposables.clear();
    if (!_completer.isCompleted) _completer.complete();
  }

  Future<void> get future => _completer.future;
}

abstract class Streamable<State extends Object?> {
  Stream<State> get stream;
}

abstract class StateStreamable<State> implements Streamable<State> {
  State get state;
}

abstract class StateStreamableSource<State>
    implements StateStreamable<State>, Closable {}

abstract class Closable {
  FutureOr<void> close();
  bool get isClosed;
}

abstract class Emittable<State extends Object?> {
  void emit(State state);
}

abstract class ErrorSink implements Closable {
  void addError(Object error, [StackTrace? stackTrace]);
}

abstract class BlocBase<State>
    implements StateStreamableSource<State>, Emittable<State>, ErrorSink {
  BlocBase(this._state) {
    _blocObserver.onCreate(this);
  }
  final _blocObserver = Bloc.observer;
  late final _stateController = StreamController<State>.broadcast();
  StreamController get controller => _stateController;
  State _state;

  bool _emitted = false;

  @override
  State get state {
    if (Observer.proxy != null) {
      Observer.proxy!.addListener(this);
    }

    return _state;
  }

  @override
  Stream<State> get stream => _stateController.stream;
  @override
  bool get isClosed => _stateController.isClosed;

  @protected
  @visibleForTesting
  @override
  void emit(State state) {
    try {
      if (isClosed) {
        throw StateError('Cannot emit new states after calling close');
      }
      if (state == _state && _emitted) return;
      onChange(Change<State>(currentState: this.state, nextState: state));
      _state = state;
      _stateController.add(_state);
      _emitted = true;
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @protected
  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onChange(this, change);
  }

  @protected
  @mustCallSuper
  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onError(this, error, stackTrace);
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onClose(this);
    await _stateController.close();
  }
}

abstract class BlocEventSink<Event extends Object?> implements ErrorSink {
  void add(Event event);
}

typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> emit,
);

typedef EventMapper<Event> = Stream<Event> Function(Event event);
typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event> events,
  EventMapper<Event> mapper,
);

abstract class Bloc<Event, State> extends BlocBase<State>
    implements BlocEventSink<Event> {
  Bloc(State initialState) : super(initialState);
  static BlocObserver observer = const _DefaultBlocObserver();
  static EventTransformer<dynamic> transformer = (events, mapper) {
    return events
        .map(mapper)
        .transform<dynamic>(const _FlatMapStreamTransformer<dynamic>());
  };

  State call([Event? event]) {
    if (event != null) {
      add(event);
    }
    return state;
  }

  final _eventController = StreamController<Event>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _handlers = <_Handler>[];
  final _emitters = <_Emitter<dynamic>>[];
  final _eventTransformer = Bloc.transformer;
  @override
  void add(Event event) {
    assert(() {
      final handlerExists = _handlers.any((handler) => handler.isType(event));
      if (!handlerExists) {
        final eventType = event.runtimeType;
        throw StateError(
          '''add($eventType) was called without a registered event handler.\n'''
          '''Make sure to register a handler via on<$eventType>((event, emit) {...})''',
        );
      }
      return true;
    }());
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onEvent(this, event);
  }

  @visibleForTesting
  @override
  void emit(State state) => super.emit(state);
  void on<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    assert(() {
      final handlerExists = _handlers.any((handler) => handler.type == E);
      if (handlerExists) {
        throw StateError(
          'on<$E> was called multiple times. '
          'There should only be a single event handler per event type.',
        );
      }
      _handlers.add(_Handler(isType: (dynamic e) => e is E, type: E));
      return true;
    }());

    final subscription = (transformer ?? _eventTransformer)(
      _eventController.stream.where((event) => event is E).cast<E>(),
      (dynamic event) {
        void onEmit(State state) {
          if (isClosed) return;
          if (this.state == state && _emitted) return;
          onTransition(
            Transition(
              currentState: this.state,
              event: event as E,
              nextState: state,
            ),
          );
          emit(state);
        }

        final emitter = _Emitter(onEmit);
        final controller = StreamController<E>.broadcast(
          sync: true,
          onCancel: emitter.cancel,
        );

        Future<void> handleEvent() async {
          void onDone() {
            emitter.complete();
            _emitters.remove(emitter);
            if (!controller.isClosed) controller.close();
          }

          try {
            _emitters.add(emitter);
            await handler(event as E, emitter);
          } catch (error, stackTrace) {
            onError(error, stackTrace);
            rethrow;
          } finally {
            onDone();
          }
        }

        handleEvent();
        return controller.stream;
      },
    ).listen(null);
    _subscriptions.add(subscription);
  }

  @protected
  @mustCallSuper
  void onTransition(Transition<Event, State> transition) {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onTransition(this, transition);
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    await _eventController.close();
    for (final emitter in _emitters) {
      emitter.cancel();
    }
    await Future.wait<void>(_emitters.map((e) => e.future));
    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
    return super.close();
  }
}

class _Handler {
  const _Handler({required this.isType, required this.type});
  final bool Function(dynamic value) isType;
  final Type type;
}

abstract class BlocObserver {
  const BlocObserver();
  @protected
  @mustCallSuper
  void onCreate(BlocBase<dynamic> bloc) {}
  @protected
  @mustCallSuper
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {}
  @protected
  @mustCallSuper
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {}
  @protected
  @mustCallSuper
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {}
  @protected
  @mustCallSuper
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {}
  @protected
  @mustCallSuper
  void onClose(BlocBase<dynamic> bloc) {}
}

class _DefaultBlocObserver extends BlocObserver {
  const _DefaultBlocObserver();
}

class _FlatMapStreamTransformer<T> extends StreamTransformerBase<Stream<T>, T> {
  const _FlatMapStreamTransformer();

  @override
  Stream<T> bind(Stream<Stream<T>> stream) {
    final controller = StreamController<T>.broadcast(sync: true);

    controller.onListen = () {
      final subscriptions = <StreamSubscription<dynamic>>[];

      final outerSubscription = stream.listen(
        (inner) {
          final subscription = inner.listen(
            controller.add,
            onError: controller.addError,
          );

          subscription.onDone(() {
            subscriptions.remove(subscription);
            if (subscriptions.isEmpty) controller.close();
          });

          subscriptions.add(subscription);
        },
        onError: controller.addError,
      );

      outerSubscription.onDone(() {
        subscriptions.remove(outerSubscription);
        if (subscriptions.isEmpty) controller.close();
      });

      subscriptions.add(outerSubscription);

      controller.onCancel = () {
        if (subscriptions.isEmpty) return null;
        final cancels = [for (final s in subscriptions) s.cancel()];
        return Future.wait(cancels).then((_) {});
      };
    };

    return controller.stream;
  }
}
