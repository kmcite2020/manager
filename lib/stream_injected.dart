// ignore_for_file: overridden_fields, annotate_overrides

part of 'manager.dart';

class StreamInjected<T> extends Injected<T> {
  Stream<T> Function() creator;
  T? _state;
  StreamSubscription<T>? subscription;
  StreamInjected(this.creator) {
    subscribe();
  }

  void subscribe() {
    subscription = creator().listen(
      (event) {
        state = event;
        notify();
      },
    );
  }

  @override
  bool get loading => _state == null;

  @override
  void reset() => subscribe();
  void dispose() => subscription?.cancel();
  @override
  Widget build(Widget Function(T state) builder) {
    return StreamBuilder(
      stream: creator(),
      builder: (context, snapshot) {
        return builder(state);
      },
    );
  }
}
