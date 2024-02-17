import '../../manager.dart';

/// NOTIFIER - CUBIT
abstract class Manager<T> extends RM<T> {
  Manager(T value) : super.create(() => value);
  T get state => super();
  set state(T newState) => super(newState);
}
