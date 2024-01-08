library manager;

import 'package:flutter/widgets.dart';

typedef Listener = void Function(void Function());
typedef Creator<T> = T Function();
final _listeners = <Listener>[];
void _addListener(Listener listener) => _listeners.add(listener);
void _removeListener(Listener listener) => _listeners.remove(listener);
// void _removeAllListeners() => _listeners.clear();

class RM {
  factory RM.create(Creator<State> creator) => RM._(creator);

  late State _state;
  final Creator<State> _creator;
  RM._(this._creator) {
    _state = _creator();
  }
  State call([State? t]) {
    if (t != null) {
      if (_state != t) {
        _state = t;
        _notifyUI();
      }
    }
    return _state;
  }

  void _notifyUI() {
    for (final ui in _listeners) {
      ui(
        () {
          // ignore: avoid_print
          if (RM._logging) print(this);
        },
      );
    }
  }

  @override
  String toString() => '$runtimeType(value:$_state)';
  static bool _logging = false;
  static void setLogging(bool value) => _logging = value;
}

abstract class UI extends StatefulWidget {
  const UI({Key? key}) : super(key: key);

  @override
  ExtendedState createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<UI> {
  late Listener listener;
  @override
  void initState() {
    super.initState();
    listener = setState;
    _addListener(listener);
  }

  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    _removeListener(listener);
    super.dispose();
  }
}
