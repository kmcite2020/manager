import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'package:manager/manager.dart';
part 'persistent_spark.dart';
part 'ui.dart';
part 'extensions.dart';
part 'sparkle_builder.dart';

class Sparkle<T> extends ISparkle<T> {
  Sparkle(this.initialState);
  @override
  final T initialState;
}

abstract class ISparkle<T> {
  bool get autoDispose => true;
  T get initialState;

  late T _value = initialState;

  StreamController<T>? _controller;

  StreamController<T> get controller {
    _controller ??= StreamController.broadcast();
    return _controller!;
  }

  bool get hasListeners => controller.hasListener;

  void set(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      controller.sink.add(_value);
    }
  }

  T get get {
    if (SparkleBuilder.proxy != null) {
      SparkleBuilder.proxy!.addListener(this);
    }
    return _value;
  }

  void apply(SparkleModifier<T> spark) {
    spark(get, set);
  }

  T newCallable([T? newState]) {
    return get;
  }

  T call([T? _newState]) {
    if (_newState != null) {
      set(_newState);
    }
    return get;
  }

  FutureOr<void> dispose() {
    _controller?.close();
  }

  FutureOr<void> close() {
    if (autoDispose) _controller?.close();
  }
}

typedef SparkleModifier<T> = void Function(T get, ValueSetter<T> set);
