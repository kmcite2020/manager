import 'manager.dart';

extension DynamicExtensions on dynamic {
  Text text({double textScaleFactor = 1, TextStyle? style}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor),
      style: style,
    );
  }
}

extension WidgetExtensions on Widget {
  Padding pad({
    double? all,
    double? right,
    double? left,
    double? top,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    EdgeInsetsGeometry edgeInsets = EdgeInsets.zero;

    if (all != null) {
      edgeInsets = EdgeInsets.all(all);
    } else if (horizontal != null || vertical != null) {
      edgeInsets = EdgeInsets.symmetric(
        vertical: vertical ?? 0.0,
        horizontal: horizontal ?? 0.0,
      );
    } else if (right != null || left != null || top != null || bottom != null) {
      edgeInsets = EdgeInsets.only(
        left: left ?? 0.0,
        right: right ?? 0.0,
        top: top ?? 0.0,
        bottom: bottom ?? 0.0,
      );
    } else {
      edgeInsets = EdgeInsets.all(8.0);
    }

    return Padding(
      padding: edgeInsets,
      child: this,
    );
  }

  Widget center() => Center(child: this);
  Card card() => Card(child: this);
}

String get randomID => Uuid().v8();

PersistState<T> persisted<T>(
  String key,
  FutureOr<T> Function(Map<String, dynamic> json)? fromJson,
) {
  return PersistState(
    key: key,
    toJson: jsonEncode,
    fromJson: (json) => fromJson!.call(jsonDecode(json)),
  );
}
