part of 'manager.dart';

class Reference<Event, State> extends Bloc<Event, State> {
  Reference(
    this.initialState, {
    required void Function(
      void Function<E extends Event>(
        HandlerFunction<E, State> fn,
      ) on,
    ) events,
  }) {
    events(on);
  }
  @override
  final State initialState;
}
