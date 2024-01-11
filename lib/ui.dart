part of 'manager.dart';

abstract class UI extends StatefulWidget {
  const UI({super.key});

  @override
  State<UI> createState() => ExtendedState();
  Widget build(BuildContext context);
}

class ExtendedState extends State<UI> {
  late Notifier notifier;
  @override
  void initState() {
    super.initState();
    notifier = setState;
    notifiers.add(notifier);
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }

  @override
  void dispose() {
    notifiers.remove(notifier);
    super.dispose();
  }
}
