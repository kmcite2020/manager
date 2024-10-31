import '../manager.dart';

abstract class TopUI extends UIv2 {
  const TopUI({super.key});

  Widget home(BuildContext context);

  ThemeMode get themeMode => ThemeMode.system;
  ThemeData get theme => ThemeData.light();
  ThemeData get darkTheme => ThemeData.dark();
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home(context),
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
    );
  }
}
