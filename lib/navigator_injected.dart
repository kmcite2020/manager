part of 'manager.dart';

class NavigatorInjected {
  final key = GlobalKey<NavigatorState>();
  BuildContext get context => key.currentContext!;
  NavigatorState get state => key.currentState!;
  GlobalKey<NavigatorState>? get navigatorKey => key;
  Future<T?> to<T extends Object?>(Widget page) {
    return state.push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void back<T extends Object?>([T? result]) {
    return state.pop(result);
  }

  Future<T?> toDialog<T>(Dialog dialog) {
    return showDialog(
      context: key.currentContext!,
      builder: (context) => dialog,
    );
  }
}

final navigator = NavigatorInjected();
