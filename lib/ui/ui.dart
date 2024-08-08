import 'dart:async';
import 'package:flutter/material.dart';
import 'dynamic_updater.dart';

abstract class UI extends StatefulWidget {
  // ignore: public_member_api_docs
  const UI({Key? key}) : super(key: key);

  /// the build function
  Widget build(BuildContext context);

  @override
  // ignore: library_private_types_in_public_api
  _ExtendedState createState() => _ExtendedState();
}

class _ExtendedState extends State<UI> {
  _ExtendedState() {
    updater = DynamicUpdater();
  }

  DynamicUpdater? updater;
  late StreamSubscription _subscription;
  bool _afterFirstLayout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      _afterFirstLayout = true;
    });
    // listen the observable events
    _subscription = updater!.listen(_rebuild);
  }

  @override
  void dispose() {
    _afterFirstLayout = false;
    // remove the subsciptions when the widget is destroyed
    _subscription.cancel();
    if (updater?.canUpdate ?? false) {
      updater?.close();
    }

    super.dispose();
  }

  void _rebuild(_) {
    if (_afterFirstLayout && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = DynamicUpdater.instance;

    DynamicUpdater.instance = updater;
    final result = widget.build(context);
    DynamicUpdater.instance = observer;
    return result;
  }
}
