import 'package:flutter/material.dart';
import 'package:manager/state_manager/management/simple.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../management/complex.dart';
import '../management/manager.dart';

typedef UI = ReactiveStatelessWidget;

class ManagerUI<E, T> extends StatelessWidget {
  final Widget Function(T state) builder;
  final Manager<E, T> manager;

  const ManagerUI({
    required this.builder,
    required this.manager,
  });
  @override
  Widget build(BuildContext context) => builder(manager.state);
}

class ComplexUI<E, T> extends StatelessWidget {
  final Widget Function(T state) builder;
  final Complex<T> complex;

  const ComplexUI({
    required this.builder,
    required this.complex,
  });
  @override
  Widget build(BuildContext context) => builder(complex.state);
}

class SimpleUI<E, T> extends StatelessWidget {
  final Widget Function(T state) builder;
  final SimpleManager<T> simple;

  const SimpleUI({
    required this.builder,
    required this.simple,
  });
  @override
  Widget build(BuildContext context) => builder(simple.state);
}
