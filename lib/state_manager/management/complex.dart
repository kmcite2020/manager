import 'simple.dart';

/// NOTIFIER - CUBIT
abstract class Complex<T> extends SimpleManager<T> {
  T? _base;
  T initialBase;
  Complex(this.initialBase) : super(() => initialBase) {
    _base = initialBase;
  }

  set data(T newData);
  set state(T newState);
  set value(T newValue);

  @override
  T call([T? newCall]) => _base!;

  @override
  T get state => _base!;
}
