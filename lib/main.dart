// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:manager/extensions.dart';
import 'package:manager/manager.dart';
import 'package:manager/settings.dart';

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

@freezed
class Safer with _$Safer {
  const factory Safer({
    @Default(7) final int g,
  }) = _Safer;

  factory Safer.fromJson(Map<String, dynamic> json) => _$SaferFromJson(json);
}

final materialColorRM = RM.create(Colors.blue);

MaterialColor get color => materialColorRM();
set color(MaterialColor value) => materialColorRM(value);

typedef ToJson<T> = Map<String, dynamic> Function(T);
ToJson toJsonFreezedClasses = (s) => s.toJson();

final saferRM = RM.create(
  const Safer(),
  save: Save.freezed(
    key: 'safer',
    fromJson: Safer.fromJson,
  ),
);
final counterRM = RM.create(
  const Counter(),
  save: Save.freezed(
    key: 'future',
    fromJson: Counter.fromJson,
  ),
);

void main() async {
  await RM.initStorage();
  await RM.deleteAllPersistentStorage();
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
      home: const HomePage(title: 'Global State Manager'),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    inform('myHomePage');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
            icon: Icon(Icons.settings),
          ).pad(),
        ],
      ),
      body: materialColorRM.build(
        (state) {
          inform('integerRM');
          return Column(
            children: [
              counterRM.build(
                (state) => Column(
                  children: [
                    state().text(textScaleFactor: 6).pad(),
                    saferRM().g.text(textScaleFactor: 6).pad(),
                    ElevatedButton(
                      onPressed: () {
                        counterRM(state.copyWith(value: 1 + 1 + state()));
                        saferRM(saferRM().copyWith(g: 1 + 1 + state()));
                      },
                      child: 'Update State'.text(),
                    ).pad(),
                  ],
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          materialColorRM(Colors.amber);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// final deleteAllStateRM = RM.future(RM.deleteAllPersistentStorage);
