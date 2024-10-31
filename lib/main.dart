import 'package:manager/manager.dart';

void main() {
  runApp(App());
}

final router = Navigation(home: Home());

class OptimizedRiverpod extends UIv2 {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => navigation(),
        ),
        title: Text('Riverpod'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: userNameBloc.state,
              onChanged: (value) => userNameBloc(ChangeUserNameEvent(value)),
              onFieldSubmitted: (value) => userNameBloc(ResetUserNameEvent()),
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              userNameBloc.state,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Bloc based API',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 16.0),
            SizedBox(height: 16.0),
            Spacer(),
            Text(
              'Riverpod based API',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: themeModeNotifier.state.index,
        items: ThemeMode.values
            .map(
              (mode) => BottomNavigationBarItem(
                icon: Icon(
                  switch (mode) {
                    ThemeMode.system => Icons.sync_sharp,
                    ThemeMode.light => Icons.light_mode,
                    ThemeMode.dark => Icons.dark_mode,
                  },
                ),
                label: mode.name,
              ),
            )
            .toList(),
        onTap: (value) {
          themeModeNotifier.specificThemeMode(
            ThemeMode.values[value],
          );
        },
      ),
    );
  }
}

class Home extends UIv2 {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          countRM.state.text(),
          'Spark/Sparkle API'.text(),
          ElevatedButton(
            onPressed: () => increment(),
            child: 'increase counter'.text(),
          ).pad(),
          ElevatedButton(
            onPressed: () => decrement(),
            child: 'decrease counter'.text(),
          ).pad(),
          ElevatedButton(
            onPressed: () {
              navigation(OptimizedRiverpod());
            },
            child: 'Go to Settings'.text(),
          ).pad(),
          'Navigation() API'.text(),
        ],
      ).center(),
    );
  }
}

void increment() => countRM.state++;
void decrement() => countRM.state--;

final countRM = Sparkle(0);

final Navigation navigation = Navigation(home: Home());

class App extends TopUI {
  @override
  Widget home(_) => navigation.widget();
}

final themeModeNotifier = ThemeModeNotifier();

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build(_) => ThemeMode.system;

  void specificThemeMode(ThemeMode? themeMode) => state = themeMode!;
  void toggleThemeMode() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
  }
}

final UserNameBloc userNameBloc = UserNameBloc();

class UserNameBloc extends Bloc<UserNameEvent, String> {
  UserNameBloc() {
    register<ChangeUserNameEvent>((event) => event(event().name));
    register<ResetUserNameEvent>((event) => event(''));
  }
  @override
  String get initialState => '';
}

class UserNameEvent {}

class ResetUserNameEvent extends UserNameEvent {}

class ChangeUserNameEvent extends UserNameEvent {
  final String name;
  ChangeUserNameEvent(this.name);
}

final CountCubit countCubit = CountCubit(0);

class CountCubit extends Cubit<int> {
  CountCubit(super.initialState);
  inc() {
    state++;
  }

  dec() {
    state--;
  }
}
