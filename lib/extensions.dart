import 'package:flutter/material.dart';

extension ObjectExtensions on Object? {
  Widget text({double? textScaleFactor}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor ?? 1),
    );
  }
}
