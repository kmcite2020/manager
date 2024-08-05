import 'package:flutter/material.dart';
import 'package:manager/manager.dart';

void main() {
  runApp(App());
}

class App extends TopUI {
  @override
  Widget home(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _store.state.text(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _store.dispatch(Increment()),
      ),
    );
  }

  @override
  Store get store => _store;
}

final _store = Store(appRM, initialState: 0);

int appRM(state, action) {
  return switch (action) {
    Increment() => state + 1,
    Decrement() => state - 1,
    _ => state,
  };
}

class Decrement {}

class Increment {}
