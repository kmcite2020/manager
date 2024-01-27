import 'package:flutter/material.dart';

import 'main.dart';

extension ObjectExtensions on Object? {
  Widget text({double? textScaleFactor}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor ?? 1),
    );
  }
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
