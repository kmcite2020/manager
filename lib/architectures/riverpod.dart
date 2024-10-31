import 'spark.dart';

abstract class Notifier<T> extends Spark<T> {
  T build(Spark<T> value);
  @override
  T get initialState => build(this);
}
