import 'dart:math';

import 'package:flutter/material.dart';
import 'package:manager/main.dart';
import 'package:manager/manager.dart';

class PersistableInjectedPage extends StatelessWidget {
  const PersistableInjectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'PersistableInjected<T>'.text(),
      ),
      body: ListView(
        children: [
          'To create a persistent RM you need a few things.'.text().pad(),
          '1. You need a "key" param. It is used to uniquely identify this object in persistent storage.'
              .text()
              .pad(),
          '2. You need a "fromJson" param. It is used to create Dart objects from underlying data in the storage.'
              .text()
              .pad(),
          '3. Your object should be a freezed and json_serializable Object.'
              .text()
              .pad(),
          'If you have done the steps above, then you are ready to create persistable reactive objects'
              .text()
              .pad(),
          persistentRM.build(
            (state) => ListTile(
              tileColor: state.materialColor,
              title: state.text(),
              onTap: () {
                final rnd = Random().nextInt(Colors.primaries.length);
                persistentRM(
                  persistentRM().copyWith(
                    materialColor: Colors.primaries[rnd],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final persistentRM = RM.persistent(
  () => GlobalStateManager(),
  key: 'gsm',
  fromJson: GlobalStateManager.fromJson,
);
