// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:manager/manager.dart';

part 'main.freezed.dart';
part 'main.g.dart';

@freezed
class Counter with _$Counter {
  const factory Counter({
    @Default(0) final int value,
  }) = _Counter;
  const Counter._();
  int call() => value;

  factory Counter.fromJson(Map<String, dynamic> json) =>
      _$CounterFromJson(json);
}

final materialColorRM = RM.create(
  () => Colors.blue,
);

MaterialColor get color => materialColorRM();
set color(MaterialColor value) => materialColorRM(value);

final counterRM = RM.create(
  () => const Counter(),
  save: Save(
    key: 'future',
    fromJson: Counter.fromJson,
    toJson: (s) => s.toJson(),
  ),
);

void main() async {
  await RM.initStorage();
  runApp(const MyApp());
}

class MyApp extends UI {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: materialColorRM()),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(title),
      // ),
      body: integerRM.build(
        (state) => Text(
          state.toString(),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     integerRM.state = 5 + integerRM.state;
      //     materialColorRM(Colors.amber);
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

final integerRM = RM.create(() => 5);
