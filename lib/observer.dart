part of 'manager.dart';

class Observer<T> {
  Spark<T?> subject = Simple(null);

  static Observer? proxy;

  final Map<Spark, List<StreamSubscription>> _subscriptions = {};
  Map<Spark, List<StreamSubscription>> get subscriptions => _subscriptions;

  bool get canUpdate => subscriptions.isNotEmpty;

  void addListener(Spark<T> cubit) {
    if (!_subscriptions.containsKey(cubit)) {
      final StreamSubscription subscription =
          cubit.stream.listen(subject.controller.add);
      final listSubscriptions = _subscriptions[cubit] ?? [];
      listSubscriptions.add(subscription);
      _subscriptions[cubit] = listSubscriptions;
    }
  }

  StreamSubscription<T?> listen(void Function(T?) _) {
    return subject.stream.listen(_);
  }

  FutureOr<void> close() async {
    for (final e in _subscriptions.values) {
      for (final subs in e) {
        await subs.cancel();
      }
    }
    _subscriptions.clear();
    return subject.close();
  }
}
