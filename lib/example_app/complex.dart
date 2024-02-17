import 'dart:async';

import 'package:manager/state_manager/management/complex.dart';

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
class CounterRM extends Complex<Event, State> {
  CounterRM()
      : super(
          State(0),
        ) {
    on<AddEvent>(_addEvent);
    on<MinusEvent>(_minusEvent);
    on<ResetEvent>(_resetEvent);
  }

  FutureOr<void> _addEvent(AddEvent event, Emitter<State> setState) {
    setState(State(call().count + event.add));
  }

  FutureOr<void> _minusEvent(MinusEvent event, Emitter<State> setState) {
    setState(State(call().count - event.minus));
  }

  FutureOr<void> _resetEvent(ResetEvent event, Emitter<State> setState) {
    setState(State(0));
  }
}

/// create an instance
final counterRM = CounterRM();
