// ignore_for_file: overridden_fields, annotate_overrides

part of 'manager.dart';

class FutureInjected<T> extends Injected<T> {
  Future<T> Function() creator;
  T? _state;
  bool _isLoading = true;
  Object? _error;

  FutureInjected(this.creator) {
    refresh();
  }

  @override
  T get state {
    if (_error != null) {
      throw _error!;
    }
    if (_isLoading || _state == null) {
      throw Exception("Data is still loading");
    }
    return _state!;
  }

  Future<void> refresh() async {
    try {
      _isLoading = true;
      _state = await creator();
      _isLoading = false;
    } catch (e) {
      _error = e;
      _isLoading = false;
    } finally {
      super.notify();
    }
  }

  @override
  bool get loading => _isLoading;

  @override
  void reset() => refresh();
  @override
  Widget build(Widget Function(T state) builder) => builder(state);
}
