library manager;

import 'package:flutter/widgets.dart';

typedef Listener = void Function(void Function());
typedef Creator<T> = T Function();
final listeners = <Listener>[];
void addListener(Listener listener) => listeners.add(listener);
void removeListener(Listener listener) => listeners.remove(listener);
void removeAllListeners() => listeners.clear();

class RM {
  static Manager<State> create<State>(
    Creator<State> creator,
  ) {
    return Manager._(creator);
  }

  static bool _logging = false;
  static void setLogging(bool value) => _logging = value;
}

class Manager<State> {
  late State _state;
  final Creator<State> _creator;
  Manager._(this._creator) {
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
    for (final ui in listeners) {
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
}

abstract class UI extends StatefulWidget {
  const UI({Key? key}) : super(key: key);

  @override
  ExtendedState createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<UI> {
  @override
  void initState() {
    super.initState();
    addListener(setState);
  }

  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    removeAllListeners();
    super.dispose();
  }
}
