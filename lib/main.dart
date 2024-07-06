// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:manager/persistent_spark.dart';
import 'package:manager/sparkle_builder.dart';

void main() => appRunner(App());

class App extends TopUI {
  @override
  Widget get navigation => navigationRM();
}

class Home extends UI {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Manager'.text(),
      ),
      body: '${counterRM.get}'.text().center(),
      floatingActionButton: ButtonBar(
        children: [
          FloatingActionButton(
            onPressed: () {
              counterRM.apply(incrementer());
            },
          ),
          FloatingActionButton(
            onPressed: () {
              Navigation('SUCCESS'.text().center());
            },
          ),
          FloatingActionButton(
            onPressed: () {
              counterRM(
                (CountState(count: 100)),
              );
            },
          ),
          FloatingActionButton(
            onPressed: () {
              counterRM.apply(incrementer());
            },
          ),
        ],
      ),
    );
  }
}

final counterRM = PersistentSparkle(
  CountState(count: 0),
  key: 'countState',
  fromJson: CountState.fromMap,
);

final navigationRM = Sparkle<Widget>(Home());
SparkleModifier<CountState> incrementer() {
  return (get, set) {
    set(
      CountState(count: get.count + 1),
    );
  };
}

class Navigation {
  final Widget page;
  Navigation(this.page) {
    navigationRM.apply(
      ((get, set) => set(page)),
    );
  }
}

class CountState {
  final int count;
  CountState({
    required this.count,
  });

  CountState copyWith({
    int? count,
  }) {
    return CountState(
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'count': count,
    };
  }

  factory CountState.fromMap(Map<String, dynamic> map) {
    return CountState(
      count: map['count'] as int,
    );
  }

  factory CountState.fromJson(String source) =>
      CountState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CountState(count: $count)';

  @override
  bool operator ==(covariant CountState other) {
    if (identical(this, other)) return true;

    return other.count == count;
  }

  @override
  int get hashCode => count.hashCode;

  String toJson() => json.encode(toMap());
}
