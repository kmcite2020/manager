import 'package:manager/state_manager/management/simple.dart';

import '../manager.dart';

final simpleCounterRM = RM(() => 5);
final borderRadiusRM = RM(() => 8.0);
final useMaterial3RM = RM(() => true);
final paddingRM = RM(() => 8.0);
final themeModeRM = RM(() => ThemeMode.system);

class HomePage extends UI {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RM.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeModeRM(),
      theme: ThemeData.light(useMaterial3: useMaterial3RM()).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusRM()),
          ),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: useMaterial3RM()).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusRM()),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('STATE MANAGER'),
        ),
        body: ListView(
          children: [
            simpleRM().text(textScaleFactor: 8).pad(),
            ElevatedButton(
              onPressed: () {
                simpleRM.state++;
              },
              child: 'Simple -> Increment'.text(),
            ).pad(),
            ElevatedButton(
              onPressed: () {
                simpleRM.state--;
              },
              child: 'Simple -> Decrement'.text(),
            ).pad(),
            ElevatedButton(
              onPressed: () => RM.toPage(ManagerExampleUI()),
              child: 'Navigate to Manager<T>'.text(),
            ).pad(),
            'Padding'.text().center().pad(),
            Slider(
              label: 'Padding',
              min: 5,
              max: 9,
              value: paddingRM(),
              onChanged: paddingRM.call,
            ).pad(),
            'BorderRadius'.text().center().pad(),
            Slider(
              label: 'BorderRadius',
              min: 0,
              max: 30,
              value: borderRadiusRM(),
              onChanged: borderRadiusRM.call,
            ).pad(),
            SwitchListTile(
              title: 'Use Material 3'.text().pad(),
              value: useMaterial3RM(),
              onChanged: useMaterial3RM.call,
            ),
            DropdownButtonFormField(
              value: themeModeRM(),
              items: ThemeMode.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: e.name.toUpperCase().text(),
                    ),
                  )
                  .toList(),
              onChanged: themeModeRM.call,
            ).pad(),
            counterRM().count.text(textScaleFactor: 4).pad(),
            TextFormField(
              initialValue: integerToAddOrMinusRM(),
              onChanged: integerToAddOrMinusRM.call,
            ).pad(),
            ElevatedButton(
              onPressed: integerToAddOrMinus == null
                  ? null
                  : () {
                      counterRM(AddEvent(integerToAddOrMinus!));
                    },
              child: 'Add Event'.text(),
            ).pad(),
            ElevatedButton(
              onPressed: integerToAddOrMinus.isNull
                  ? null
                  : () {
                      counterRM(MinusEvent(integerToAddOrMinus!));
                    },
              child: 'Minus Event'.text(),
            ).pad(),
            ElevatedButton(
              onPressed: () {
                counterRM(ResetEvent());
              },
              child: 'Reset Event'.text(),
            ).pad(),
            ElevatedButton(
              onPressed: () {
                RM.clearStorage();
              },
              child: 'CLEAR ALL PERSISTENT STATE'.text(),
            ).pad(),
          ],
        ),
      ),
    );
  }
}

final integerToAddOrMinusRM = RM(() => '1');
int? get integerToAddOrMinus => int.tryParse(integerToAddOrMinusRM());
