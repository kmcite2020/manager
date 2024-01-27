import 'package:flutter/material.dart';
import 'package:manager/state_manager/management/simple.dart';
import '../../manager.dart';
import '../management/complex.dart';
import '../management/manager.dart';

abstract class UI extends StatefulWidget {
  const UI({super.key});

  @override
  State<UI> createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<UI> {
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

class ManagerUI<E, T> extends UI {
  final Widget Function(T state) builder;
  final Manager<E, T> manager;

  const ManagerUI({
    required this.builder,
    required this.manager,
  });
  @override
  Widget build(BuildContext context) => builder(manager.state);
}

class ComplexUI<E, T> extends UI {
  final Widget Function(T state) builder;
  final Complex<T> complex;

  const ComplexUI({
    required this.builder,
    required this.complex,
  });
  @override
  Widget build(BuildContext context) => builder(complex.state);
}

class SimpleUI<E, T> extends UI {
  final Widget Function(T state) builder;
  final Simple<T> simple;

  const SimpleUI({
    required this.builder,
    required this.simple,
  });
  @override
  Widget build(BuildContext context) => builder(simple.state);
}
