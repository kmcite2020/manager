// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:manager/state_manager/ui/widgets.dart';

import '../../manager.dart';
import 'readonly.dart';

typedef Creator<T> = T Function();

/// GLOBAL STATE MANAGEMENT
class Simple<T> extends Readonly<T> {
  T? _base;
  Creator<T> creator;
  Simple(this.creator) {
    recreate();
  }
  void recreate() {
    _base = creator();
  }

  void setState(T state) => notify(() => _base = state);

  void notify(void Function() modifier) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        for (final setState in setStates) {
          setState(modifier);
        }
      },
    );
  }

  set data(T newData) => setState(newData);
  set state(T newState) => setState(newState);
  set value(T newValue) => setState(newValue);

  T call([T? newCall]) {
    if (newCall != null) setState(newCall);
    return _base!;
  }

  @override
  T get data => _base!;

  @override
  T get state => _base!;

  @override
  T get value => _base!;
  Widget build(Widget Function(T state) builder) => SimpleUI(
        builder: builder,
        simple: this,
      );
}
