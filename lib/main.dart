// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'manager.dart';

void main() {
  runApp(const App());
}

class App extends UI {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: RM.navigatorKey,
      home: Scaffold(
        body: Column(
          children: [
            Text(
              counterRM().toString(),
            ),
            ElevatedButton(
              onPressed: () {
                counterRM(counterRM() + 1);
              },
              child: const Text('+'),
            ),
          ],
        ),
      ),
    );
  }
}

final streamRM = RM.stream(
  () => Stream.periodic(
    const Duration(seconds: 1),
    (x) => x,
  ),
);

final computeRM = RM.future(getApplicationDocumentsDirectory);
final counterRM = RM.simple(() => 0);
