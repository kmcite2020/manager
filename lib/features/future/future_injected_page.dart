import 'package:flutter/material.dart';
import 'package:manager/main.dart';
import 'package:manager/manager.dart';
import 'package:path_provider/path_provider.dart';

class FutureInjectedPage extends UI {
  const FutureInjectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'FutureInjected<T>'.text(),
      ),
      body: Column(
        children: [
          futureRM.build(
            (state) => Column(
              children: [
                state.text(),
                state.text(),
                state.text(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final futureRM = RM.future(getApplicationDocumentsDirectory);
