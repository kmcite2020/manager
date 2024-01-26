// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: overridden_fields

part of 'manager.dart';

class SimpleInjected<T> extends Injected<T> {
  @override
  T? initialState;
  @override
  T get state => initialState!;
  @override
  set state(T t) {
    initialState = t;
    notify();
  }

  @override
  T call([T? t]) => t != null ? state = t : state;

  @override
  void notify() => WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          for (final notifier in notifiers) {
            notifier(() {});
          }
        },
      );

  T Function() creator;
  SimpleInjected(this.creator) {
    initialState = creator();
  }

  @override
  void reset() {
    state = creator();
  }

  bool get initial => state == creator();
  @override
  Widget build(
    Widget Function(T state) builder,
  ) {
    return SimpleUI<T>(
      simpleInjected: this,
      builder: (state) => builder(state),
    );
  }

  @override
  bool get loading => throw UnimplementedError();

  Widget on(
    Widget Function() loading,
    Widget Function(dynamic e, dynamic t) error,
    Widget Function(T state) data,
  ) {
    try {
      if (initial) {
        return loading();
      } else {
        return data(state);
      }
    } catch (e) {
      return error(e, e);
    }
  }

  @override
  void update(T t) {
    // TODO: implement update
  }
}

class SimpleUI<T> extends GUI {
  const SimpleUI({
    required this.builder,
    required this.simpleInjected,
  });
  final Widget Function(T context) builder;
  final SimpleInjected<T> simpleInjected;
  @override
  Widget build(BuildContext context) => builder(simpleInjected.state);
}
