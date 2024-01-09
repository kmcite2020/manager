import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manager/extensions.dart';
import 'package:manager/manager.dart';

class SettingsPage extends UI {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Settings'.text(),
      ),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              RM.deleteAllPersistentStorage();
            },
            child: 'Delete All Persistent State'.text(),
          ).pad(),
          ValueListenableBuilder(
            valueListenable: RM.saver.box.listenable(),
            builder: (_, box, ___) {
              return Column(
                children: [
                  box.keys.text(),
                  box.values.text(),
                ],
              );
            },
          ),
          ...reactiveModels.map(
            (e) => ListTile(
              onTap: () {},
              title: e.text().pad(),
              subtitle: (e.state as Object?).text(),
            ),
          ),
        ],
      ),
    );
  }
}
