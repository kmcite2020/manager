import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:manager/features/future/future_injected_page.dart';
import 'package:manager/features/persistent/persistent_injected_page.dart';

import 'manager.dart';
import 'features/simple/simple_injected_page.dart';
import 'features/stream/stream_injected_page.dart';
part 'main.g.dart';
part 'main.freezed.dart';

void main() async {
  await RM.initStorage();
  await RM.deletePersistentStates();
  runApp(const SignalApp());
}

class App extends UI {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final state = gsmRM();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: RM.navigatorKey,
      theme: FlexThemeData.light(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: state.materialColor,
        ),
        lightIsWhite: true,
        subThemesData: const FlexSubThemesData(defaultRadius: 8),
      ),
      darkTheme: FlexThemeData.dark(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: state.materialColor,
          brightness: Brightness.dark,
        ),
        darkIsTrueBlack: true,
        subThemesData: const FlexSubThemesData(defaultRadius: 8),
      ),
      themeMode: state.themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends UI {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Global State Manager'.text(),
        backgroundColor: gsmRM().materialColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: 'SimpleInjected<T>'.text(),
            onTap: () => navigator.to(const SimpleInjectedPage()),
          ),
          ListTile(
            title: 'StreamInjected<T>'.text(),
            onTap: () => navigator.to(const StreamInjectedPage()),
          ),
          ListTile(
            title: 'FutureInjected<T>'.text(),
            onTap: () => navigator.to(const FutureInjectedPage()),
          ),
          ListTile(
            title: 'PersistableInjected<T>'.text(),
            onTap: () => navigator.to(const PersistableInjectedPage()),
          ),
        ],
      ).pad(),
    );
  }
}

extension X on Object? {
  Widget text({double? textScaleFactor}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor ?? 1),
    );
  }
}

extension Y on Widget {
  Widget pad({double? textScaleFactor}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: this,
    );
  }
}

final gsmRM = RM.simple(
  () => GlobalStateManager(),
);

@freezed
class GlobalStateManager with _$GlobalStateManager {
  factory GlobalStateManager.raw({
    @Default(Colors.blue)
    @MaterialColorConverter()
    final MaterialColor materialColor,
    @Default(ThemeMode.system) final ThemeMode themeMode,
  }) = _GlobalStateManager;
  GlobalStateManager._();
  GlobalStateManager call(GlobalStateManager gsm) => gsmRM(gsm);

  factory GlobalStateManager() => GlobalStateManager.raw();
  factory GlobalStateManager.fromJson(json) =>
      _$GlobalStateManagerFromJson(json);
}

class MaterialColorConverter implements JsonConverter<MaterialColor, int> {
  const MaterialColorConverter();
  @override
  MaterialColor fromJson(int json) => Colors.primaries[json];

  @override
  int toJson(MaterialColor object) => Colors.primaries.indexOf(object);
}

class SignalApp extends StatelessWidget {
  const SignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            futureRM.build(
              (state) => state.text(),
            ),
            DropdownButtonFormField(
              items: ThemeMode.values
                  .map(
                    (eachThemeMode) => DropdownMenuItem(
                      value: eachThemeMode,
                      child: eachThemeMode.name.toUpperCase().text(),
                    ),
                  )
                  .toList(),
              onChanged: (themeMode) {},
            ).pad(),
          ],
        ),
      ),
    );
  }
}
