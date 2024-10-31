import 'package:manager/manager.dart';

/// class to add dynamic updates into a UI widget
class DynamicUpdater<T> {
  // observable to listen the events from other observable localled in a RxBuilder Widget
  Spark<T?> dynamicUpdaterRM = Sparkle(null);

  /// used to create a tmp RxNotifier since a RxBuilder Widget
  static DynamicUpdater? instance;

  /// store the subscriptions for one observable
  final Map<Spark, List<StreamSubscription>> _subscriptions = {};
  Map<Spark, List<StreamSubscription>> get subscriptions => _subscriptions;

  // used by the RxBuilder to check if the builder method contains an observable
  bool get canUpdate => subscriptions.isNotEmpty;

  void subscribe(Spark<T> spark) {
    // if the current observable is not in the subscriptions
    if (!_subscriptions.containsKey(spark)) {
      // create a Subscription for this observable
      final StreamSubscription subscription =
          spark.stream.listen(dynamicUpdaterRM.controller.add);

      /// get the subscriptions for this Rx and add the new subscription
      final listSubscriptions = _subscriptions[spark] ?? [];
      listSubscriptions.add(subscription);
      _subscriptions[spark] = listSubscriptions;
    }
  }

  /// used by the GUI/UIv2 to listen the changes in a observable
  StreamSubscription<T?> listen(void Function(T?) _) {
    return dynamicUpdaterRM.stream.listen(_);
  }

  /// Closes the subscriptions for this RM, releasing the resources.
  FutureOr<void> close() async {
    for (final subscription in _subscriptions.values) {
      for (final subs in subscription) {
        await subs.cancel();
      }
    }
    _subscriptions.clear();
    return dynamicUpdaterRM.close();
  }
}
