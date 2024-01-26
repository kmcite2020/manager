import 'dart:io';

import 'package:colornames/colornames.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'manager.dart';
import 'reactive_x.dart';

final simpleCounterRM = RM.writable(5);
final themeModeRM = RM.writable(ThemeMode.system);
final materialColorRM = RM.writable(Colors.blue);
final borderRadiusRM = RM.writable(8.0);
final useMaterial3 = RM.writable(true);
final paddingRM = RM.writable(8.0);
late Directory directory;

final directoryRM = RM.readable(
  getApplicationDocumentsDirectory(),
);

void main() {
  runApp(const App());
}

class App extends GUI {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration(milliseconds: 700),
      themeMode: themeModeRM(),
      theme: FlexThemeData.light(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: materialColorRM(),
        ),
        subThemesData: FlexSubThemesData(
          defaultRadius: borderRadiusRM(),
        ),
        useMaterial3: useMaterial3(),
        lightIsWhite: true,
      ),
      darkTheme: FlexThemeData.dark(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: materialColorRM(),
          brightness: Brightness.dark,
        ),
        subThemesData: FlexSubThemesData(
          defaultRadius: borderRadiusRM(),
        ),
        useMaterial3: useMaterial3(),
        darkIsTrueBlack: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('STATE MANAGER'),
        ),
        body: ListView(
          children: [
            '${simpleCounterRM.value}'.text(textScaleFactor: 5).pad(),
            ElevatedButton(
              onPressed: () {
                simpleCounterRM(
                  simpleCounterRM() + 1,
                );
              },
              child: '+'.text(textScaleFactor: 2),
            ).pad(),
            ElevatedButton(
              onPressed: () {
                simpleCounterRM(
                  simpleCounterRM() - 1,
                );
              },
              child: '-'.text(textScaleFactor: 2),
            ).pad(),
            DropdownButtonFormField(
              value: themeModeRM(),
              items: ThemeMode.values
                  .map(
                    (eachThemeMode) => DropdownMenuItem(
                      child: eachThemeMode.name.toUpperCase().text(),
                      value: eachThemeMode,
                    ),
                  )
                  .toList(),
              onChanged: (_) => themeModeRM(_!),
            ).pad(),
            DropdownButtonFormField(
              value: materialColorRM(),
              items: Colors.primaries
                  .map(
                    (eachThemeMode) => DropdownMenuItem(
                      child: eachThemeMode.colorName.toUpperCase().text(),
                      value: eachThemeMode,
                    ),
                  )
                  .toList(),
              onChanged: (_) => materialColorRM(_!),
            ).pad(),
            'Padding'.text().center().pad(),
            Slider(
              label: 'Padding',
              min: 5,
              max: 9,
              value: paddingRM(),
              onChanged: paddingRM.update,
            ).pad(),
            'BorderRadius'.text().center().pad(),
            Slider(
              label: 'BorderRadius',
              min: 0,
              max: 30,
              value: borderRadiusRM(),
              onChanged: borderRadiusRM.update,
            ).pad(),
            SwitchListTile(
              title: 'Use Material 3'.text().pad(),
              value: useMaterial3(),
              onChanged: useMaterial3.update,
            ),
            setStates.text().pad(),
          ],
        ),
      ),
    );
  }
}
