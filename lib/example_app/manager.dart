import 'package:flutter/material.dart';
import 'package:manager/example_app/example_app.dart';
import 'package:manager/extensions.dart';
import 'package:manager/state_manager/management/manager.dart';
import 'package:manager/state_manager/ui/ui.dart';

class CounterState {
  final int count;
  CounterState(this.count);
}

class CounterStateRM extends Cubit<CounterState> {
  CounterStateRM()
      : super(
          CounterState(0),
        );
  void incrementCounter([int by = 1]) {
    call(CounterState(call().count + by));
  }

  void decrementCounter([int by = 1]) {
    state = CounterState(state.count - by);
  }

  void resetCounter() {
    state = CounterState(0);
  }
}

final counterStateRM = CounterStateRM();

class ManagerExampleUI extends UI {
  const ManagerExampleUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          counterStateRM().count.text(textScaleFactor: 4).pad(),
          TextFormField(
            initialValue: integerToAddOrMinusRM(),
            onChanged: integerToAddOrMinusRM.call,
          ).pad(),
          ElevatedButton(
            onPressed: integerToAddOrMinus == null
                ? null
                : () {
                    counterStateRM.incrementCounter(integerToAddOrMinus!);
                  },
            child: 'Add Counter by $integerToAddOrMinus'.text(),
          ).pad(),
          ElevatedButton(
            onPressed: integerToAddOrMinus == null
                ? null
                : () {
                    counterStateRM.decrementCounter(integerToAddOrMinus!);
                  },
            child: 'Minus Counter by $integerToAddOrMinus'.text(),
          ).pad(),
          FloatingActionButton.extended(
            onPressed: counterStateRM().count == 0
                ? null
                : () {
                    counterStateRM.resetCounter();
                  },
            label: 'Reset Counter'.text(),
            disabledElevation: 0,
          ).pad(),
        ],
      ),
    );
  }
}
