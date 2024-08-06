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
      body: _store.state.text().center(),
      floatingActionButton: ButtonBar(
        children: [
          FloatingActionButton(
            onPressed: () => _store.apply(Increment()),
          ),
          FloatingActionButton(
            onPressed: () => _store.apply(Decrement()),
          ),
        ],
      ),
    );
  }

  get store => _store;
}

final _store = Store(0);

class Decrement extends Act<int> {
  @override
  act(state, _, __) => state - 1;
}

class Increment extends Act<int> {
  @override
  act(state, _, __) => state + 1;
}
