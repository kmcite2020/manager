import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:manager/extensions.dart';

import 'manager.dart';

final simpleCounterRM = RM.simple(() => 5);
final borderRadiusRM = RM.simple(() => 8.0);
final useMaterial3 = RM.simple(() => true);
final paddingRM = RM.simple(() => 8.0);

final periodicValuesRM = RM.stream(
  () => Stream.periodic(
    Duration(seconds: 1),
    (x) {
      return x;
    },
  ),
);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RM.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration(milliseconds: 700),
      theme: FlexThemeData.light(
        subThemesData: FlexSubThemesData(
          defaultRadius: borderRadiusRM(),
        ),
        useMaterial3: useMaterial3(),
        lightIsWhite: true,
      ),
      darkTheme: FlexThemeData.dark(
        subThemesData: FlexSubThemesData(
          defaultRadius: borderRadiusRM(),
        ),
        useMaterial3: useMaterial3(),
        darkIsTrueBlack: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STATE MANAGER'),
      ),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: 'child'.text(),
          ).pad(),
          Slider(
            label: 'Padding',
            min: 5,
            max: 9,
            value: paddingRM(),
            onChanged: paddingRM.setState,
          ).pad(),
          'BorderRadius'.text().center().pad(),
          Slider(
            label: 'BorderRadius',
            min: 0,
            max: 30,
            value: borderRadiusRM(),
            onChanged: borderRadiusRM.setState,
          ).pad(),
          SwitchListTile(
            title: 'Use Material 3'.text().pad(),
            value: useMaterial3(),
            onChanged: useMaterial3.setState,
          ),
          setStates.text().pad(),
        ],
      ),
    );
  }
}
