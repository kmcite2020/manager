import 'dart:async';

import 'package:manager/manager.dart';
import 'package:manager/state_manager/management/bloc.dart';

/// create events
class Event {}

class AddEvent extends Event {
  final int add;

  AddEvent([this.add = 1]);
}

class MinusEvent extends Event {
  final int minus;

  MinusEvent([this.minus = 1]);
}

class ResetEvent extends Event {}

/// create state or states
class State {
  final int count;
  State(this.count);
}

/// create complex
class CounterRM extends Bloc<Event, State> {
  @override
  State get initialState => State(0);
  @override
  Persistor<State>? get persistor {
    return Persistor(
      key: 'key',
      toJson: (s) => {'count': s.count},
      fromJson: (count) => State(count['count'] as int),
    );
  }

  CounterRM() {
    register<AddEvent>(_addEvent);
    register<MinusEvent>(_minusEvent);
    register<ResetEvent>(_resetEvent);
  }

  FutureOr<void> _addEvent(AddEvent event, Emitter<State> setState) {
    setState(State(state.count + event.add));
  }

  FutureOr<void> _minusEvent(MinusEvent event, Emitter<State> setState) {
    setState(State(state.count - event.minus));
  }

  FutureOr<void> _resetEvent(ResetEvent event, Emitter<State> setState) {
    setState(State(0));
  }
}

/// create an instance
final counterRM = CounterRM();

class Calculator {
  int sum(int a, int b) {
    return a + b;
  }

  minus() {}
}

final calculator = Calculator();

final count = RM(
  () => 0,
);

void main(List<String> args) {
  inc();
}

void inc() {
  count.call(count() + 1);
}
