import 'dart:async';

import '../ui/ui.dart';

typedef StreamCreator<T> = Stream<T> Function();

class StreamRM<T> {
  final StreamCreator<T> streamCreator;
  late final RMI<T> rmi;
  late StreamSubscription<T> _streamSubscription;
  T? initialState;
  StreamRM(this.streamCreator, {this.initialState}) {
    start();
  }
  start() => _streamSubscription = streamCreator().listen(
        (newState) => rmi.state = newState,
      );
  dispose() {
    _streamSubscription.cancel();
    rmi.dispose();
  }
}
