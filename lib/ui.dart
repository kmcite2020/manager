part of 'manager.dart';

abstract class UI extends StatefulWidget {
  const UI({super.key});

  Widget build(BuildContext context);
  @override
  ExtendedState createState() => ExtendedState();
}

class ExtendedState extends State<UI> {
  ExtendedState() {
    _observer = Observer();
  }

  Observer? _observer;
  late StreamSubscription _subscription;
  bool _afterFirstLayout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      _afterFirstLayout = true;
    });
    _subscription = _observer!.listen(_rebuild);
  }

  @override
  void dispose() {
    _afterFirstLayout = false;
    _subscription.cancel();
    if (_observer?.canUpdate ?? false) {
      _observer?.close();
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
    final observer = Observer.proxy;

    Observer.proxy = _observer;
    final result = widget.build(context);
    if (!_observer!.canUpdate) {
      throw FlutterError(
        'If you are seeing this error, you probably did not insert any Cubit, Bloc, Reference, RM or Store<T> variables into UI.',
      );
    }
    Observer.proxy = observer;
    return result;
  }
}
