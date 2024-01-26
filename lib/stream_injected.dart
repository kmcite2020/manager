// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'manager.dart';

class StreamInjected<T> extends Injected<T> {
  // ignore: annotate_overrides, overridden_fields
  T? initialState;
  @override
  bool get loading => initialState == null;
  Stream<T> Function() creator;
  StreamSubscription<T>? subscription;

  StreamInjected(
    this.creator, {
    this.initialState,
  }) {
    reset();
  }

  @override
  void reset() {
    subscription = creator().listen(
      (event) {
        state = event;
        notify();
      },
    );
  }

  @override
  void notify() {
    for (final notifier in notifiers) {
      notifier(
        () {},
      );
    }
  }

  @override
  T get state => initialState!;
  @override
  set state(T value) => initialState = value;
  @override
  Widget build(Widget Function(T state) builder) {
    return StreamUI(
      injected: this,
      builder: builder,
    );
  }

  void dispose() {
    // subscription?.cancel();
    // inform('dispose happened');
  }

  @override
  T call([T? t]) => initialState!;

  @override
  void update(T t) {
    // TODO: implement update
  }
}

class StreamUI<T> extends GUI {
  const StreamUI({
    super.key,
    required this.injected,
    required this.builder,
  });
  final StreamInjected<T> injected;
  final Widget Function(T state) builder;

  @override
  Widget build(BuildContext context) {
    if (injected.loading) {
      return const CircularProgressIndicator().pad();
    } else {
      return builder(injected.state);
    }
  }
}
