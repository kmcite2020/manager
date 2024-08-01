part of 'manager.dart';

class StoreProvider<S> extends InheritedWidget {
  final Store<S> _store;
  const StoreProvider({
    Key? key,
    required Store<S> store,
    required Widget child,
  })  : _store = store,
        super(key: key, child: child);

  static Store<S> of<S>(BuildContext context, {bool listen = true}) {
    final provider = switch (listen) {
      true => context.dependOnInheritedWidgetOfExactType<StoreProvider<S>>(),
      false => context
          .getElementForInheritedWidgetOfExactType<StoreProvider<S>>()
          ?.widget,
    } as StoreProvider<S>?;
    return switch (provider == null) {
      true => throw StoreProviderError<StoreProvider<S>>(),
      false => provider!._store,
    };
  }

  @override
  bool updateShouldNotify(StoreProvider<S> oldWidget) =>
      _store != oldWidget._store;
}

typedef Widget ModelBuilder<Model>(BuildContext context, Model model);
typedef Model StoreConverter<S, Model>(Store<S> store);
typedef void OnInit<S>(Store<S> store);
typedef void OnDispose<S>(Store<S> store);
typedef bool IgnoreChangeTest<S>(S state);
typedef void OnWillChange<Model>(Model? prev, Model next);
typedef void OnDidChange<Model>(Model? prev, Model net);
typedef OnInitialBuild<ViewModel> = void Function(ViewModel viewModel);

class StoreConnector<S, T> extends StatelessWidget {
  final ModelBuilder<T> builder;
  final StoreConverter<S, T> converter;
  final bool distinct;
  final OnInit<S>? onInit;
  final OnDispose<S>? onDispose;
  final bool rebuildOnChange;
  final IgnoreChangeTest<S>? ignoreChange;
  final OnWillChange<T>? onWillChange;
  final OnDidChange<T>? onDidChange;
  final OnInitialBuild<T>? onInitialBuild;
  const StoreConnector({
    Key? key,
    required this.builder,
    required this.converter,
    this.distinct = false,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.ignoreChange,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _StoreStreamListener<S, T>(
      store: StoreProvider.of<S>(context),
      builder: builder,
      converter: converter,
      distinct: distinct,
      onInit: onInit,
      onDispose: onDispose,
      rebuildOnChange: rebuildOnChange,
      ignoreChange: ignoreChange,
      onWillChange: onWillChange,
      onDidChange: onDidChange,
      onInitialBuild: onInitialBuild,
    );
  }
}

class StoreBuilder<S> extends StatelessWidget {
  static Store<S> _identity<S>(Store<S> store) => store;
  final ModelBuilder<Store<S>> builder;
  final bool rebuildOnChange;
  final OnInit<S>? onInit;
  final OnDispose<S>? onDispose;
  final OnWillChange<Store<S>>? onWillChange;
  final OnDidChange<Store<S>>? onDidChange;
  final OnInitialBuild<Store<S>>? onInitialBuild;
  const StoreBuilder({
    Key? key,
    required this.builder,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<S, Store<S>>(
      builder: builder,
      converter: _identity,
      rebuildOnChange: rebuildOnChange,
      onInit: onInit,
      onDispose: onDispose,
      onWillChange: onWillChange,
      onDidChange: onDidChange,
      onInitialBuild: onInitialBuild,
    );
  }
}

class _StoreStreamListener<S, T> extends StatefulWidget {
  final ModelBuilder<T> builder;
  final StoreConverter<S, T> converter;
  final Store<S> store;
  final bool rebuildOnChange;
  final bool distinct;
  final OnInit<S>? onInit;
  final OnDispose<S>? onDispose;
  final IgnoreChangeTest<S>? ignoreChange;
  final OnWillChange<T>? onWillChange;
  final OnDidChange<T>? onDidChange;
  final OnInitialBuild<T>? onInitialBuild;

  const _StoreStreamListener({
    Key? key,
    required this.builder,
    required this.store,
    required this.converter,
    this.distinct = false,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.ignoreChange,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StoreStreamListenerState<S, T>();
  }
}

class _StoreStreamListenerState<S, T>
    extends State<_StoreStreamListener<S, T>> {
  late Stream<T> _stream;
  T? _latestValue;
  Object? _latestError;
  T get _requireLatestValue => _latestValue as T;

  @override
  void initState() {
    widget.onInit?.call(widget.store);
    _computeLatestValue();
    if (widget.onInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onInitialBuild!(_requireLatestValue),
      );
    }
    _createStream();
    super.initState();
  }

  @override
  void dispose() {
    widget.onDispose?.call(widget.store);
    super.dispose();
  }

  @override
  void didUpdateWidget(_StoreStreamListener<S, T> oldWidget) {
    _computeLatestValue();
    if (widget.store != oldWidget.store) {
      _createStream();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _computeLatestValue() {
    try {
      _latestError = null;
      _latestValue = widget.converter(widget.store);
    } catch (e, s) {
      _latestValue = null;
      _latestError = ConverterError(e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.rebuildOnChange) {
      true => StreamBuilder<T>(
          stream: _stream,
          builder: (context, snapshot) {
            if (_latestError != null) throw _latestError!;

            return widget.builder(
              context,
              _requireLatestValue,
            );
          },
        ),
      false => switch (_latestError != null) {
          true => throw _latestError!,
          false => widget.builder(context, _requireLatestValue),
        },
    };
  }

  bool _whereDistinct(T vm) {
    if (widget.distinct) {
      return vm != _latestValue;
    }

    return true;
  }

  bool _ignoreChange(S state) {
    if (widget.ignoreChange != null) {
      return !widget.ignoreChange!(widget.store.state);
    }

    return true;
  }

  void _createStream() {
    _stream = widget.store.onChange
        .where(_ignoreChange)
        .map((_) => widget.converter(widget.store))
        .transform(
          StreamTransformer.fromHandlers(
            handleError: _handleConverterError,
          ),
        )
        .where(_whereDistinct)
        .transform(
          StreamTransformer.fromHandlers(
            handleData: _handleChange,
          ),
        )
        .transform(
          StreamTransformer.fromHandlers(
            handleError: _handleError,
          ),
        );
  }

  void _handleChange(T model, EventSink<T> sink) {
    _latestError = null;
    widget.onWillChange?.call(_latestValue, model);
    final previousValue = _latestValue;
    _latestValue = model;
    if (widget.onDidChange != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onDidChange!(previousValue, _requireLatestValue);
        }
      });
    }
    sink.add(model);
  }

  void _handleConverterError(
    Object error,
    StackTrace stackTrace,
    EventSink<T> sink,
  ) {
    sink.addError(ConverterError(error, stackTrace), stackTrace);
  }

  void _handleError(
    Object error,
    StackTrace stackTrace,
    EventSink<T> sink,
  ) {
    _latestValue = null;
    _latestError = error;
    sink.addError(error, stackTrace);
  }
}

class StoreProviderError<S> extends Error {
  StoreProviderError();
  @override
  String toString() {
    return '''Error: No $S found. To fix, please try:
          
  * Wrapping your MaterialApp with the StoreProvider<State>, 
  rather than an individual Route
  * Providing full type information to your Store<State>, 
  StoreProvider<State> and StoreConnector<State, ViewModel>
  * Ensure you are using consistent and complete imports. 
  E.g. always use `import 'package:my_app/app_state.dart';
  
If none of these solutions work, please file a bug at:
https://github.com/brianegan/flutter_redux/issues/new
      ''';
  }
}

class ConverterError extends Error {
  final Object error;
  @override
  final StackTrace stackTrace;
  ConverterError(this.error, this.stackTrace);
  @override
  String toString() {
    return '''Converter Function Error: $error
    
$stackTrace;
''';
  }
}
