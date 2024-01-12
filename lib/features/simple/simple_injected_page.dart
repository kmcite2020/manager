// ignore_for_file: deprecated_member_use

import 'package:colornames/colornames.dart';
import 'package:flutter/material.dart';
import 'package:manager/main.dart';

class SimpleInjectedPage extends StatelessWidget {
  const SimpleInjectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'SimpleInjected<T>'.text(),
      ),
      body: gsmRM.build(
        (state) => Column(
          children: [
            'An app to demonstrate the SimpleInjected<T>'
                .text(textScaleFactor: 2)
                .pad(),
            DropdownButtonFormField(
              value: state.materialColor,
              items: Colors.primaries
                  .map(
                    (eachMaterialColor) => DropdownMenuItem(
                      value: eachMaterialColor,
                      child: eachMaterialColor.colorName.toUpperCase().text(),
                    ),
                  )
                  .toList(),
              onChanged: (materialColor) {
                state(state.copyWith(materialColor: materialColor!));
              },
            ).pad(),
            DropdownButtonFormField(
              value: state.themeMode,
              items: ThemeMode.values
                  .map(
                    (eachThemeMode) => DropdownMenuItem(
                      value: eachThemeMode,
                      child: eachThemeMode.name.toUpperCase().text(),
                    ),
                  )
                  .toList(),
              onChanged: (themeMode) {
                gsmRM(gsmRM().copyWith(themeMode: themeMode!));
              },
            ).pad(),
            ElevatedButton(
              onPressed: gsmRM.initial
                  ? null
                  : () {
                      gsmRM.reset();
                    },
              child: 'Simple Reset'.text(),
            ).pad(),
            ...[
              'initial: ${gsmRM.initial}'.text(),
              'state: ${gsmRM.state}'.text(),
              'hashCode: ${gsmRM.hashCode}'.text(),
              'runtimeType: ${gsmRM.runtimeType}'.text(),
            ].map(
              (e) => e.pad(),
            ),
          ],
        ),
      ),
    );
  }
}
