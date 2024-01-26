// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'main.dart';

extension ObjectExtensions on Object? {
  Widget text({double? textScaleFactor}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor ?? 1),
    );
  }
}

extension WidgetExtensions on Widget {
  Widget pad({double? textScaleFactor}) {
    return Padding(
      padding: EdgeInsets.all(paddingRM()),
      child: this,
    );
  }

  Widget center() => Center(child: this);
}

abstract class Value<T> {
  Value(this.initialState) {
    _value = initialState;
  }
  // ignore: unused_field
  late T _value;
  T initialState;
  T get value;
  set value(T newValue);
  T call([T? t]);
  void update(T _value);
}

class Reading<T> extends Value<T> {
  Reading(this.initialValue) : super(initialValue) {
    _value = initialValue;
  }
  late T _value, initialValue;
  T get value => _value;
  set value(T _newValue) => _value = _newValue;

  T call([
    T? _newValueNullable,
  ]) {
    if (_newValueNullable != null) {
      value = _newValueNullable;
    }
    return value;
  }

  void update(T _value) => value = _value;

  Widget build(
      Widget Function(
        T value,
      ) builder) {
    return GetBuilder(
      builder: (value) {
        return builder(value);
      },
      provider: this,
    );
  }
}

class Writable<T> extends Value<T> {
  Writable(super.initialValue);

  @override
  T get value => _value;
  @override
  set value(T _newValue) => notify(() => _value = _newValue);

  void notify(void Function() toRun) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        for (final setState in setStates) {
          setState(toRun);
        }
      },
    );
  }

  Widget build(
          Widget Function(
            T value,
            void Function(T value) onChanged,
          ) builder) =>
      WritableBuilder(
        builder: builder,
        provider: this,
      );

  @override
  T call([T? t]) {
    if (t != null) {
      value = t;
    }
    return value;
  }

  @override
  void update(T _value) => value = _value;
}

typedef Setstate = void Function(void Function());

final setStates = <Setstate>{};

class FutureValue<T> extends Value<T> {
  FutureValue(
    super.initialState,
  );
  @override
  late T value;

  @override
  T call([T? t]) {
    // TODO: implement call
    throw UnimplementedError();
  }

  @override
  void update(T _value) {
    // TODO: implement update
  }
}

class GetBuilder<T> extends StatelessWidget {
  const GetBuilder({
    required this.builder,
    required this.provider,
  });
  final Reading<T> provider;
  final Widget Function(T value) builder;
  @override
  Widget build(BuildContext context) => builder(provider.value);
}

class WritableBuilder<T> extends GUI {
  const WritableBuilder({
    required this.provider,
    required this.builder,
  });
  final Writable<T> provider;
  final Widget Function(
    T value,
    void Function(T newValue) onChanged,
  ) builder;

  @override
  Widget build(BuildContext context) => builder(
        provider.value,
        provider.update,
      );
}

abstract class GUI extends StatefulWidget {
  const GUI({super.key});

  @override
  State<GUI> createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<GUI> {
  late Setstate _setState;
  @override
  void initState() {
    super.initState();
    _setState = setState;
    setStates.add(_setState);
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }

  @override
  void dispose() {
    setStates.remove(_setState);
    super.dispose();
  }
}
