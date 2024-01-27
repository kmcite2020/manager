import 'package:colornames/colornames.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:manager/extensions.dart';
import 'package:path_provider/path_provider.dart';

import 'manager.dart';
import 'navigator_injected.dart';
import 'state_manager/management/complex.dart';
import 'state_manager/management/manager.dart';

final simpleCounterRM = RM.simple(() => 5);
final materialColorRM = RM.complex(MaterialColorRM());
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

final directoryRM = RM.future(getApplicationDocumentsDirectory);
final themeModeRM = RM.manager(ThemeModeRM());

class MaterialColorRM extends Complex<MaterialColor> {
  MaterialColorRM() : super(Colors.amber);
  void onChanged(MaterialColor? materialColor) => setState(materialColor!);
}

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return themeModeRM.build(
      (themeMode) => materialColorRM.build(
        (materialColor) => MaterialApp(
          navigatorKey: RM.navigatorKey,
          debugShowCheckedModeBanner: false,
          themeAnimationDuration: Duration(milliseconds: 700),
          themeMode: themeMode,
          theme: FlexThemeData.light(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: materialColor,
              brightness: Brightness.light,
            ),
            subThemesData: FlexSubThemesData(
              defaultRadius: borderRadiusRM(),
            ),
            useMaterial3: useMaterial3(),
            lightIsWhite: true,
          ),
          darkTheme: FlexThemeData.dark(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: materialColor,
              brightness: Brightness.dark,
            ),
            subThemesData: FlexSubThemesData(
              defaultRadius: borderRadiusRM(),
            ),
            useMaterial3: useMaterial3(),
            darkIsTrueBlack: true,
          ),
          home: HomePage(),
        ),
      ),
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
          '${simpleCounterRM.value}'.text(textScaleFactor: 5).pad(),
          periodicValuesRM.loading
              ? CircularProgressIndicator().pad()
              : periodicValuesRM().text(textScaleFactor: 5).pad(),
          directoryRM.loading
              ? CircularProgressIndicator().pad()
              : directoryRM().text().pad(),
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
              navigator.to(HomePage());
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
            onChanged: (_) {
              themeModeRM.add(ThemeModeEvent(_!));
            },
          ).pad(),
          DropdownButtonFormField(
            value: materialColorRM.state,
            items: Colors.primaries
                .map(
                  (eachThemeMode) => DropdownMenuItem(
                    child: eachThemeMode.colorName.toUpperCase().text(),
                    value: eachThemeMode,
                  ),
                )
                .toList(),
            onChanged: materialColorRM.onChanged,
          ).pad(),
          'Padding'.text().center().pad(),
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

class ThemeModeRM extends Manager<ThemeModeEvent, ThemeMode> {
  ThemeModeRM() : super(ThemeMode.system) {
    on<ThemeModeEvent>((event, emit) => emit(event.themeMode));
  }
}

class ThemeModeEvent {
  final ThemeMode themeMode;
  ThemeModeEvent(this.themeMode);
}
