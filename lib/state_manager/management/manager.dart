import '../../manager.dart';

typedef Notifier<State> = Manager<State>;
typedef Cubit<State> = Manager<State>;

abstract class Manager<State> extends RM<State> {
  Manager(State state) : super.create(() => state);
  State get state => super();
  set state(State newState) => super(newState);
}
