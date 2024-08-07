import 'dart:async';

import 'dynamic_updater.dart';

class Sparkle<T> extends Spark<T> {
  @override
  final T initialState;
  Sparkle(this.initialState);
}

/// RM class to work with observables
abstract class Spark<T> {
  T get initialState;
  late T _state = initialState;

  /// StreamController to emit the changes in the current observable
  StreamController<T>? _controller;

  StreamController<T> get controller {
    _controller ??= StreamController.broadcast();
    return _controller!;
  }

  /// stream for the current observable
  Stream<T> get stream => controller.stream;

  /// returns true if the current observable has listeners
  bool get hasListeners => controller.hasListener;

  /// update the value and add a event sink to the [StreamController]
  set state(T newValue) {
    if (_state != newValue) {
      _state = newValue;
      controller.sink.add(_state);
    }
  }

  /// returns the current value for this observable
  T get state {
    // if we have a UI accessing to the current value
    // we add a listener for that Widget
    if (DynamicUpdater.dynamicUpdater != null) {
      DynamicUpdater.dynamicUpdater!.subscribe(this);
    }
    return _state;
  }

  /// close the [StreamController] for this observable
  FutureOr<void> close() => _controller?.close();
}
