// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:manager/manager.dart';

void main() {
  Store.init().then(
    (_) {
      runApp(App());
    },
  );
}

class App extends TopUI {
  @override
  Widget home(context) {
    return Scaffold(
      appBar: AppBar(),
      body: switch (store.loading) {
        false => store.state.text().center(),
        _ => CircularProgressIndicator(),
      },
      floatingActionButton: ButtonBar(
        children: [
          FloatingActionButton(
            onPressed: () => _store.apply(DoubleInc()),
          ),
          FloatingActionButton(
            onPressed: () => _store.apply(Decrement()),
          ),
        ],
      ),
    );
  }

  Store<Serri> get store => _store;
}

final _store = Store<Serri>(
  Serri(count: 0),
  middlewares: [
    LoggingMW(),
  ],
  fromJson: Serri.fromMap,
);

class LoggingMW extends Middleware<Serri> {
  @override
  apply(Store<Serri> store, Act<Serri> act, NextDispatcher<Serri> next) async {
    print(act);
    next(act);
  }
}

class Decrement extends Act<Serri> {
  @override
  reduce(state) => state.copyWith(count: state.count - 1);
}

class Increment extends Act<Serri> {
  @override
  reduce(state) => state.copyWith(count: state.count + 1);
}

class DoubleInc extends Act<Serri> {
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
