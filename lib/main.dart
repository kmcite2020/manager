import 'package:flutter/material.dart';
import 'package:manager/manager.dart';

void main() {
  runApp(App());
}

class App extends TopUI {
  @override
  Widget home(context) {
    return Scaffold(
      appBar: AppBar(),
      body: store.state.text().center(),
      floatingActionButton: ButtonBar(
        children: [
          FloatingActionButton(
            onPressed: () => _store.apply(DoubleInc()),
          ),
          FloatingActionButton(
            onPressed: () => _store.apply(Decrement()),
          ),
        ],
      ),
    );
  }

  Store<int> get store => _store;
}

final _store = Store(
  0,
  middlewares: [
    LoggingMW(),
  ],
);

class LoggingMW extends Middleware<int> {
  @override
  void apply(Store<int> store, Act<int> act, NextDispatcher<int> next) {
    print(act);
    next(act);
  }
}

class Decrement extends Act<int> {
  @override
  reduce(state) => state - 1;
}

class Increment extends Act<int> {
  @override
  reduce(state) => state + 1;
}

class DoubleInc extends Act<int> {
  @override
  int reduce(int state) {
    return state + 2;
  }
}
