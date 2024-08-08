import 'package:manager/architectures/spark.dart';

import '../manager.dart';

void riverpod(Widget app) => runApp(app);

abstract class Notifier<T> extends Spark<T> {
  @override
  final T initialState;
  Notifier(this.initialState);
}

// class AsyncNotifier<T> {
//   final T initialState;
//   late final Spark<T?> sparkRM = Sparkle(initialState);
//   final Spark<String> errorRM;
//   final Spark<bool> loadingRM;

//   AsyncNotifier(this.initialState);
//   T spark([T? value]) {
//     if (value != null) {
//       sparkRM.state = value;
//     }
//     return sparkRM.state;
//   }

//   bool loading([bool? value]) {
//     if (value != null) {
//       loadingRM.state = value;
//     }
//     return loadingRM.state;
//   }

//   String error([String? value]) {
//     if (value != null) {
//       errorRM.state = value;
//     }
//     return errorRM.state;
//   }
// }
