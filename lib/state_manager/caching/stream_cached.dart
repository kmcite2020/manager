// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manager/extensions.dart';

import '../../manager.dart';
import '../management/readonly.dart';

typedef StreamCreator<T> = Stream<T> Function();

class StreamCached<T> extends Readonly<T> {
  bool _isLoading = true;
  T? _base;
  bool get loading => _base == null;
  Stream<T> Function() creator;
  StreamSubscription<T>? _subscription;
  StreamCached(this.creator) {
    restart();
  }

  void notify(void Function() modifier) {
    WidgetsBinding.instance.addPersistentFrameCallback(
      (timeStamp) {
        for (final setState in setStates) {
          setState(modifier);
        }
      },
    );
  }

  T call() => _base!;

  @override
  T get data => _base!;
  @override
  T get state => _base!;
  @override
  T get value => _base!;
  void restart() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = creator().listen(
      (newValue) => notify(
        () => _base = newValue,
      ),
    );
    _isLoading = false;
  }

  Widget build(Widget Function(T state) builder) {
    if (loading) return CircularProgressIndicator().pad();
    return builder(state);
  }

  void dispose() {
    _subscription?.cancel();
    _isLoading = true;
  }
}
