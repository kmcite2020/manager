part of 'manager.dart';

extension DynamicExtensions on dynamic {
  Widget text({double textScaleFactor = 1}) => Text(toString());
}

extension WidgetExtensions on Widget {
  Widget pad({EdgeInsets custom = const EdgeInsets.all(8)}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: this,
    );
  }

  Widget center() {
    return Center(
      child: this,
    );
  }
}
