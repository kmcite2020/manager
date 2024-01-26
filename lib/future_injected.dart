// ignore_for_file: overridden_fields, annotate_overrides

part of 'manager.dart';

class FutureInjected<T> extends Injected<T> {
  T? initialState;
  bool get loading => initialState == null;
  Future<T> Function() creator;
  FutureInjected(this.creator) {
    reset();
  }

  void reset() async {
    state = await creator();
  }

  void notify() {
    for (final notifier in notifiers) {
      notifier(
        () {},
      );
    }
  }

  T call([T? t]) {
    if (t != null) state = t;
    return state;
  }

  T get state => initialState!;
  set state(T value) {
    initialState = value;
    notify();
  }

  Widget build(Widget Function(T state) builder) {
    return FutureBuilder(
      builder: (context, snapshot) {
        const indicator = CircularProgressIndicator();
        final data = snapshot.data;
        if (data == null) {
          return indicator;
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return indicator;
            case ConnectionState.done:
              return builder(data);
          }
        }
      },
      future: this.creator(),
    );
  }

  void dispose() {
    // subscription?.cancel();
    // inform('dispose happened');
  }

  @override
  void update(T t) {
    initialState = t;
    notify();
  }
}
