// ignore_for_file: unused_field

import 'package:flutter/material.dart';

import '../management/readonly.dart';

class Cached<T> extends Readonly<T> {
  T? _base;
  Cached(T base) : _base = base;

  @override
  T get data => _base!;

  @override
  T get state => _base!;

  @override
  T get value => _base!;
  Widget build(Widget Function(T state) builder) {
    return builder(state);
  }
}
