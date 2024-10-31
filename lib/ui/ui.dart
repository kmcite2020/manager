import '../manager.dart';
import 'dynamic_updater.dart';

class GUI extends UIv2 {
  final Widget Function(BuildContext context) builder;
  const GUI(this.builder, {super.key});
  @override
  Widget build(BuildContext context) => builder(context);
}

abstract class UIv2 extends StatefulWidget {
  const UIv2({super.key});
  Widget build(BuildContext context);

  @override
  _ExtendedState createState() => _ExtendedState();
}

class _ExtendedState extends State<UIv2> {
  _ExtendedState() {
    updater = DynamicUpdater();
  }

  DynamicUpdater? updater;
  late StreamSubscription _subscription;
  bool _afterFirstLayout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      _afterFirstLayout = true;
    });
    // listen the observable events
    _subscription = updater!.listen(_rebuild);
  }

  @override
  void dispose() {
    _afterFirstLayout = false;
    // remove the subsciptions when the widget is destroyed
    _subscription.cancel();
    if (updater?.canUpdate ?? false) {
      updater?.close();
    }

    super.dispose();
  }

  void _rebuild(_) {
    if (_afterFirstLayout && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = DynamicUpdater.instance;
    DynamicUpdater.instance = updater;
    final result = widget.build(context);
    DynamicUpdater.instance = observer;
    return result;
  }
}
