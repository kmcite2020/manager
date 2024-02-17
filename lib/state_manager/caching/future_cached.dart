import 'package:manager/extensions.dart';

import '../ui/ui.dart';

typedef FutureCreator<T> = Future<T> Function();

class FutureRM<T> {
  final FutureCreator<T> futureCreator;
  final T? initialState;
  FutureRM(this.futureCreator, {this.initialState}) {
    initialize();
  }
  void initialize() async {
    final created = await futureCreator();
    rmi = RMI(
      creator: () => created,
      initialState: initialState,
      autoDisposeWhenNotUsed: false,
      stateInterceptorGlobal: null,
    );
  }

  late final RMI<T> rmi;
  T call() => rmi.state;
  bool get loading {
    try {
      return !rmi.isNotNull;
    } catch (e) {
      print(e);
      return true;
    }
  }
}
