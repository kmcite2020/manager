// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:manager/extensions.dart';

import '../../manager.dart';
import '../management/readonly.dart';

typedef FutureCreator<T> = Future<T> Function();

class FutureCached<T> extends Readonly<T> {
  bool _isLoading = true;
  FutureCreator<T> creator;
  FutureCached(this.creator) {
    refresh();
  }
  void refresh() async {
    _isLoading = true;
    _base = await creator();
    _isLoading = false;
    notify(() {});
  }

  void notify(void Function() modifier) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        for (final setState in setStates) {
          setState(modifier);
        }
      },
    );
  }

  T? _base;
  bool get loading => _base == null || _isLoading;
  T call() => _base!;
  Widget build(Widget Function(T state) builder) {
    if (loading) return CircularProgressIndicator().pad();
    return builder(state);
  }

  @override
  T get data => _base!;

  @override
  T get state => _base!;

  @override
  T get value => _base!;
}
