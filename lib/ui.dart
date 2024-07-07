part of 'manager.dart';

abstract class TopUI extends UI {
  Widget get navigation;
  ThemeData get theme => ThemeData.light();
  ThemeData get darkTheme => ThemeData.dark();
  ThemeMode get themeMode => ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: navigation,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
    );
  }
}

void appRunner(TopUI app) => PersistentSparkle.init.then(
      (value) => runApp(app),
    );

abstract class UI extends StatefulWidget {
  const UI({Key? key}) : super(key: key);

  Widget build(BuildContext context);

  @override
  _UIState createState() => _UIState();
}

class _UIState extends State<UI> {
  _UIState() {
    _observer = SparkleBuilder();
  }

  SparkleBuilder? _observer;
  late StreamSubscription _subscription;
  bool _afterFirstLayout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      _afterFirstLayout = true;
    });
    // listen the observable events
    _subscription = _observer!.listen(_rebuild);
  }

  @override
  void dispose() {
    _afterFirstLayout = false;
    // remove the subsciptions when the widget is destroyed
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
    final observer = SparkleBuilder.proxy;

    SparkleBuilder.proxy = _observer;
    final result = widget.build(context);
    // if (!_observer!.canUpdate) {
    //   throw FlutterError(
    //     '''
    //   If you are seeing this error, you probably did not insert any observable variables into RxBuilder
    //   ''',
    //   );
    // }
    SparkleBuilder.proxy = observer;
    return result;
  }
}
