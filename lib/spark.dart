part of 'manager.dart';

abstract class Spark<T> {
  T get initialState;
  late T _state = initialState;

  StreamController<T>? _controller;
  StreamController<T> get controller {
    _controller ??= StreamController.broadcast();
    return _controller!;
  }

  Stream<T> get stream => controller.stream;
  @visibleForTesting
  bool get hasListeners => controller.hasListener;
  set state(T newState) {
    if (_state != newState) {
      _state = newState;
      controller.sink.add(_state);
    }
  }

  T get state {
    if (Observer.proxy != null) {
      Observer.proxy!.addListener(this);
    }
    return _state;
  }

  void emit(T toEmit) => state = toEmit;

  FutureOr<void> close() => _controller?.close();
}
