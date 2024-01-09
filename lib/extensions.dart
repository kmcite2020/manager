import 'package:flutter/material.dart';

extension ObjectExtensions on Object? {
  Widget text({double? textScaleFactor}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor ?? 1),
    );
  }
}

extension WidgetExtensions on Widget {
  Widget pad({double? padding_}) {
    return Padding(
      padding: EdgeInsets.all(padding_ ?? 8),
      child: this,
    );
  }

  Widget center({double? textScaleFactor}) {
    return Center(child: this);
  }
}
