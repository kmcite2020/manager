import 'package:flutter/material.dart';

class _NavigationRM {
  final key = GlobalKey<NavigatorState>();
  BuildContext get context => key.currentContext!;
  NavigatorState get state => key.currentState!;
  GlobalKey<NavigatorState>? get navigatorKey => key;
  Future<T?> toPage<T extends Object?>(Widget page) {
    return state.push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  late final back = state.pop;
  Future<T?> toDialog<T>(Dialog dialog) {
    return showDialog(
      context: key.currentContext!,
      builder: (context) => dialog,
    );
  }
}

final navigator = _NavigationRM();
