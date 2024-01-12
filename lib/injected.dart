part of 'manager.dart';

abstract class Injected<T> {
  /// Is Initialised
  bool get loading;

  /// Initial State
  T? initialState;

  /// Standard API -> .state
  T get state;
  set state(T t);

  /// Callable API -> ()
  T call([T? t]);

  /// Notification to UI
  void notify();

  /// UI -> Builder Pattern
  Widget build(Widget Function(T state) builder);

  /// Reset Injected State
  void reset();
}
