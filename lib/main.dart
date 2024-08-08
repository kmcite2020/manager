import 'package:flutter/material.dart' hide Action;
import 'package:manager/extensions.dart';

import 'architectures/redux.dart';
import 'ui/top_ui.dart';

void main() => redux(App());

class App extends TopUI {
  @override
  Widget home(context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: 'dec'.text(),
          ).pad(),
          ElevatedButton(
            onPressed: () {},
            child: 'inc'.text(),
          ).pad(),
        ],
      ).center(),
    );
  }
}
