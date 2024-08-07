import 'dart:async';
import 'package:manager/rm.dart';

/// class to add dynamic updates into a UI widget
class DynamicUpdater<T> {
  // observable to listen the events from other observable localled in a RxBuilder Widget
  Spark<T?> dynamicUpdaterRM = Sparkle(null);

  /// used to create a tmp RxNotifier since a RxBuilder Widget
  static DynamicUpdater? dynamicUpdater;

  /// store the subscriptions for one observable
  final Map<Spark, List<StreamSubscription>> _subscriptions = {};
  Map<Spark, List<StreamSubscription>> get subscriptions => _subscriptions;

  // used by the RxBuilder to check if the builder method contains an observable
  bool get canUpdate => subscriptions.isNotEmpty;

  void subscribe(Spark<T> rm) {
    // if the current observable is not in the subscriptions
    if (!_subscriptions.containsKey(rm)) {
      // create a Subscription for this observable
      final StreamSubscription subscription = rm.stream.listen(dynamicUpdaterRM.controller.add);

      /// get the subscriptions for this Rx and add the new subscription
      final listSubscriptions = _subscriptions[rm] ?? [];
      listSubscriptions.add(subscription);
      _subscriptions[rm] = listSubscriptions;
    }
  }

  /// used by the RxBuilder to listen the changes in a observable
  StreamSubscription<T?> listen(void Function(T?) _) {
    return dynamicUpdaterRM.stream.listen(_);
  }

  /// Closes the subscriptions for this RM, releasing the resources.
  FutureOr<void> close() async {
    for (final e in _subscriptions.values) {
      for (final subs in e) {
        await subs.cancel();
      }
    }
    _subscriptions.clear();
    return dynamicUpdaterRM.close();
  }
}
