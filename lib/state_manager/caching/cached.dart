// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:manager/state_manager/management/simple.dart';

class Cached<T> extends SimpleManager<T> {
  T? _base;
  Cached(T base)
      : _base = base,
        super(() => base);

  @override
  T get state => _base!;

  Widget build(Widget Function(T state) builder) {
    return builder(state);
  }
}
