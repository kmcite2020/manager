part of 'sparkle_builder.dart';

class SparkleBuilder<T> {
  // observable to listen the events from other observable localled in a RxBuilder Widget
  ISparkle<T?> subject = Sparkle(null);

  /// used to create a tmp RxNotifier since a RxBuilder Widget
  static SparkleBuilder? proxy;

  /// store the subscriptions for one observable
  final Map<ISparkle, List<StreamSubscription>> _subscriptions = {};
  Map<ISparkle, List<StreamSubscription>> get subscriptions => _subscriptions;

  // used by the RxBuilder to check if the builder method contains an observable
  bool get canUpdate => subscriptions.isNotEmpty;

  void addListener(ISparkle<T> rx) {
    // if the current observable is not in the subscriptions
    if (!_subscriptions.containsKey(rx)) {
      // create a Subscription for this observable
      final StreamSubscription subs =
          rx.controller.stream.listen(subject.controller.add);

      /// get the subscriptions for this Rx and add the new subscription
      final listSubscriptions = _subscriptions[rx] ?? [];
      listSubscriptions.add(subs);
      _subscriptions[rx] = listSubscriptions;
    }
  }

  /// used by the RxBuilder to listen the changes in a observable
  StreamSubscription<T?> listen(void Function(T?) _) {
    return subject.controller.stream.listen(_);
  }

  /// Closes the subscriptions for this Rx, releasing the resources.
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
