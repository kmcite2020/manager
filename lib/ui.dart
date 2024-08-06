part of 'manager.dart';

typedef UI = _UI<dynamic>;

abstract class TopUI<T> extends StatelessWidget {
  const TopUI({super.key});

  Spark<T> get store;

  GlobalKey<NavigatorState>? get navigatorKey => null;
  Widget home(BuildContext context);

  ThemeMode get themeMode => ThemeMode.system;
  ThemeData get theme => ThemeData();
  ThemeData get darkTheme => ThemeData.dark();

  @override
  Widget build(context) {
    return StoreProvider(
      store: store,
      child: StoreBuilder<T>(
        builder: (context, store) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: home(context),
            themeMode: themeMode,
            theme: theme,
            darkTheme: darkTheme,
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}

abstract class _UI<S> extends StatefulWidget {
  static Spark<S> _identity<S>(Spark<S> store) => store;
  final bool rebuildOnChange;
  final OnInit<S>? onInit;
  final OnDispose<S>? onDispose;
  final OnWillChange<Spark<S>>? onWillChange;
  final OnDidChange<Spark<S>>? onDidChange;
  final OnInitialBuild<Spark<S>>? onInitialBuild;
  const _UI({
    Key? key,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);
  Widget build(BuildContext context);
  @override
  State<_UI<S>> createState() => _UIState<S>();
}

class _UIState<S> extends State<_UI<S>> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<S, Spark<S>>(
      builder: (context, store) => widget.build(context),
      converter: _UI._identity,
      rebuildOnChange: widget.rebuildOnChange,
      onInit: widget.onInit,
      onDispose: widget.onDispose,
      onWillChange: widget.onWillChange,
      onDidChange: widget.onDidChange,
      onInitialBuild: widget.onInitialBuild,
    );
  }
}
