part of 'manager.dart';

abstract class Injected<T> {
  bool get loading;

  /// Standard API -> .state
  T? _state;
  T get state => _state!;
  set state(T t) {
    _state = t;
    notify();
  }

  /// Callable API
  T call([T? t]) {
    if (t != null) {
      state = t;
    }
    return state;
  }

  /// Notification to UI
  void notify() => WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          for (final notifier in notifiers) {
            notifier(() {});
          }
        },
      );

  /// UI -> Builder Pattern
  Widget build(Widget Function(T state) builder);
  void reset();
}
