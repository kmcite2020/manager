import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager/manager.dart';

void main() => runApp(App());

typedef RModifier<T> = void Function(T get, ValueSetter<T> set);

class RM<T> {
  late T _value = initialState;
  final T initialState;
  RM(this.initialState);

  StreamController<T> controller = StreamController.broadcast();

  bool get hasListeners => controller.hasListener;

  void set(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      controller.sink.add(_value);
    }
  }

  T get state {
    if (instance != null) {
      instance!.ui(this);
    }
    return _value;
  }

  void apply(RModifier<T> modifier) {
    modifier(state, set);
  }

  T call([T? _newState]) {
    if (_newState != null) {
      set(_newState);
    }
    return state;
  }

  FutureOr<void> dispose() {
    controller.close();
  }

  void ui(RM<T> rx) {
    if (!subscriptions.containsKey(rx)) {
      final StreamSubscription subs = rx.controller.stream.listen(instance?.controller.add);
      final listSubscriptions = subscriptions[rx] ?? [];
      listSubscriptions.add(subs);
      subscriptions[rx] = listSubscriptions;
    }
  }

  StreamSubscription? listen(void Function(dynamic) _) {
    return instance?.controller.stream.listen(_);
  }

  static RM? instance = RM(null);
  final Map<RM, List<StreamSubscription>> subscriptions = {};
}

abstract class TopUI extends UI {
  Widget get navigation;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: navigation,
    );
  }
}

class App extends TopUI {
  @override
  Widget get navigation => HomePage();
}

class HomePage extends UI {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: countRM.state.text(textScaleFactor: 10).center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          countRM.set(countRM.state + 1);
        },
      ),
    );
  }
}

final countRM = RM(0);
