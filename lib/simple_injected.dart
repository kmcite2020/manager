// ignore_for_file: overridden_fields

part of 'manager.dart';

class SimpleInjected<T> extends Injected<T> {
  T Function() creator;
  @override
  T? _state;
  SimpleInjected(this.creator) {
    _state = creator();
  }

  @override
  void reset() {
    state = creator();
  }

  @override
  bool get loading => _state == null;
  @override
  Widget build(Widget Function(T state) builder) => builder(state);
}
