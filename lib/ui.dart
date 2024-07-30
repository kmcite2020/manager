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
    // _observer = SparkleBuilder();
  }

  RM? _instance;
  StreamSubscription? _subscription;
  bool _afterFirstLayout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      _afterFirstLayout = true;
    });
    // listen the observable events
    _subscription = _instance?.listen(_rebuild);
  }

  @override
  void dispose() {
    _afterFirstLayout = false;
    _subscription?.cancel();
    if (_instance?.controller.hasListener ?? false) {
      _instance?.dispose();
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
    final observer = RM.instance;

    RM.instance = _instance;
    final result = widget.build(context);
    // if (!_observer!.canUpdate) {
    //   throw FlutterError(
    //     '''
    //   If you are seeing this error, you probably did not insert any observable variables into RxBuilder
    //   ''',
    //   );
    // }
    RM.instance = observer;
    return result;
  }
}

class Spark<T> {
  final T Function() creator;
  final void Function(T prev, T next) beforeMutation;
  final void Function() afterMutation;
  final StreamController<T> controller = StreamController.broadcast();

  late T spark = creator();
  Object? error;
  bool isLoading = false;

  Spark(
    this.creator,
    this.beforeMutation,
    this.afterMutation,
  ) {
    controller.add(spark);
  }

  bool get loading => isLoading;
  T get state => spark;

  set state(T newState) {
    try {
      isLoading = true;
      beforeMutation(state, newState);
      controller.add(newState);
      afterMutation();
      isLoading = false;
    } catch (e) {
      error = e as Exception;
    }
  }
}
