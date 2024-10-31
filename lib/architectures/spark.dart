import '../manager.dart';
import '../ui/dynamic_updater.dart';

/// A [Sparkle] class that extends [Spark] and holds an initial state of type [T].
///
/// The [Sparkle] class provides a [StreamController] to emit changes in the current observable,
/// and methods to update the state and retrieve the current state. It also checks if there are
/// any listeners for the observable.
///
/// The [Spark] class is an abstract class that provides the basic functionality for working
/// with observables, including the [stream], [state], and [close] methods.
class Sparkle<T> extends Spark<T> {
  @override
  final T initialState;
  Sparkle(this.initialState);
}

/// Spark class to work with observables
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
  set state(T newState) {
    if (_state != newState) {
      _state = newState;
      controller.sink.add(_state);
    }
  }

  /// returns the current value for this observable
  T get state {
    // if we have a UI accessing to the current value
    // we add a listener for that Widget
    if (DynamicUpdater.instance != null) {
      DynamicUpdater.instance!.subscribe(this);
    }
    return _state;
  }

  /// close the [StreamController] for this observable
  FutureOr<void> close() => _controller?.close();
}
