// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:manager/state_manager/ui/widgets.dart';

import 'simple.dart';

/// NOTIFIER - CUBIT
abstract class Complex<T> extends Simple<T> {
  T? _base;
  T initialBase;
  Complex(this.initialBase) : super(() => initialBase) {
    _base = initialBase;
  }

  set data(T newData);
  set state(T newState);
  set value(T newValue);

  @override
  T call([T? newCall]) => _base!;

  @override
  T get data => _base!;

  @override
  T get state => _base!;

  @override
  T get value => _base!;
  Widget build(Widget Function(T state) builder) => ComplexUI(
        builder: builder,
        complex: this,
      );
}
