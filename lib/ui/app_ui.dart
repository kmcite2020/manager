import '../manager.dart';

abstract class ImperativeUI extends UI {
  const ImperativeUI({super.key});

  Widget home(BuildContext context);

  ThemeMode get themeMode => ThemeMode.system;
  ThemeData get theme => ThemeData.light();
  ThemeData get darkTheme => ThemeData.dark();
  Map<String, Widget Function(BuildContext)>? get routes => null;
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
      navigatorKey: routes != null ? null : RM.navigate.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: home(context),
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routes: routes ?? {},
    );
  }
}

abstract class DeclarativeUI extends UI {
  InjectedNavigator get router;

  ThemeMode get themeMode => ThemeMode.system;
  ThemeData get theme => ThemeData.light();
  ThemeData get darkTheme => ThemeData.dark();

  const DeclarativeUI({super.key});
  @override
  didMountWidget(_) => FlutterNativeSplash.remove();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
