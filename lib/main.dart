// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'manager.dart';

void main() => runApp(const App());

final themeModeRM = Store(
  ThemeMode.system,
  middlewares: [
    ThemeModeLogger(),
  ],
);

class SpecificThemeModeAction extends Act<ThemeMode> {
  final ThemeMode themeMode;

  const SpecificThemeModeAction(this.themeMode);
  @override
  ThemeMode reduce(ThemeMode state) => themeMode;
}

class ThemeModeLogger extends Middleware<ThemeMode> {
  @override
  Future<void> call(
    Store<ThemeMode> store,
    Act<ThemeMode> action,
    NextDispatcher<ThemeMode> next,
  ) async {
    if (action is SpecificThemeModeAction) {
      log('PRETTY -> ${action.themeMode.name.toUpperCase()}');
    }
    next(action);
  }
}

class App extends TopUI {
  const App({super.key});

  @override
  Widget homePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField(
          value: themeModeRM.state,
          items: ThemeMode.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.name.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (value) {
            themeModeRM.dispatch(
              SpecificThemeModeAction(
                value ?? ThemeMode.system,
              ),
            );
          },
        ),
      ),
    );
  }
}

abstract class TopUI extends UI {
  const TopUI({super.key});
  Widget homePage(BuildContext context);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homePage(context),
      themeMode: themeModeRM.state,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
