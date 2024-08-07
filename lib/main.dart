import 'dart:convert';
import 'package:flutter/material.dart' hide Action;
import 'package:manager/manager.dart';

import 'top_ui.dart';

void main() {
  RUN(App());
}

class App extends TopUI {
  @override
  Widget home(context) {
    return Scaffold(
      appBar: AppBar(),
      body: store.build(
        (_) {
          return _.text();
        },
      ).center(),
      floatingActionButton: ButtonBar(
        children: [
          FloatingActionButton(
            onPressed: () => store(DoubleInc()),
          ),
          FloatingActionButton(
            onPressed: () => store(Decrement()),
          ),
        ],
      ),
    );
  }
}

final store = Store<Serri>(
  Serri(count: 0),
  middlewares: [
    LoggingMW(),
  ],
  fromJson: Serri.fromMap,
  key: 'app_stateww',
);

class LoggingMW extends Middleware<Serri> {
  @override
  apply(Store<Serri> store, Action<Serri> act, NextDispatcher<Serri> next) async {
    print(act);
    next(act);
  }
}

class Decrement extends Action<Serri> {
  @override
  reduce(state) => state.copyWith(count: state.count - 1);
}

class Increment extends Action<Serri> {
  @override
  reduce(state) => state.copyWith(count: state.count + 1);
}

class DoubleInc extends Action<Serri> {
  @override
  reduce(state) async {
    await Future.delayed(Duration(seconds: 2));
    return state.copyWith(count: state.count + 2);
  }
}

class Serri {
  final int count;
  Serri({required this.count});
  Serri copyWith({int? count}) => Serri(count: count ?? this.count);
  factory Serri.fromMap(Map<String, dynamic> map) => Serri(count: map['count'] as int);
  factory Serri.fromJson(String source) =>
      Serri.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => <String, dynamic>{'count': count};
  String toJson() => json.encode(toMap());
  @override
  String toString() => 'Serri(count: $count)';
  @override
  bool operator ==(covariant Serri other) {
    if (identical(this, other)) return true;
    return other.count == count;
  }

  @override
  int get hashCode => count.hashCode;
}
