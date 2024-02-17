import 'package:flutter/material.dart';
import 'package:manager/manager.dart';

import 'example_app/example_app.dart';

extension ObjectExtensions on Object? {
  Widget text({double? textScaleFactor}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor ?? 1),
    );
  }

  bool get isNotNull => this != null;
}

extension WidgetExtensions on Widget {
  Widget pad({double? textScaleFactor}) => Padding(
        padding: EdgeInsets.all(
          paddingRM(),
        ),
        child: this,
      );
  Widget center() => Center(child: this);
}

extension CreatedExtensionsBool on RM<bool> {
  void toggle() => this(!this());
}

extension CreatedExtensionsInt on RM<int> {
  void increment() => this(this() + 1);
  void decrement() => this(this() - 1);
}
