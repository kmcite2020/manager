# manager

A new Global State Manger.

## Getting Started

Heavily inspired from States_Rebuilder library.


## Adding library to your project
```yaml
  manager:
    git: https://github.com/kmcite2020/manager
```

## Recommended packages
build_runner

json_annotation

json_serializable

freezed

freezed_annotation

Persistence of state works with these libraries. Only objects with created with json_serializable can be persisted.

### Simple Usage
``` dart
final materialColorRM = RM.create(
  () => Colors.blue,
);

MaterialColor get color => materialColorRM();
set color(MaterialColor value) => materialColorRM(value);
```
### Reacting to changes in RMs
To make UI react to the changes in the created state. Implement UI widget instead of Stateless or Statefull widget
```dart
class ExampleWidget extends UI {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: materialColorRM(),
        ),
      ),
    );
  }
}
```
### Use the build method on RM
or use build method on the createdRM object.
```dart
final integerRM = RM.create(() => 5);
class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: integerRM.build(
        (state) => Text(
          state.toString(),
        ),
      ),
    );
  }
}
```
by using Stateless Widget we still can rebuild UI when we use the build method of created object and we can acess current state too.
### Persistence
You can persist your state.
When creating a State pass Save() object and your state will be easily persistable.

Also you need to enablePersistence.
```dart
void main() async {
  /// Use this method to enable persistence
  await RM.initStorage();
}
```

### For example for this freezed class
```dart
@freezed
class Counter with _$Counter {
  const factory Counter({
    @Default(0) final int value,
  }) = _Counter;
  const Counter._();
  int call() => value;

  factory Counter.fromJson(Map<String, dynamic> json) =>
      _$CounterFromJson(json);
}
```
```dart
final counterRM = RM.create(
  const Counter(),
  save: Save.freezed(
    key: 'future',
    fromJson: Counter.fromJson,
  ),
);
```
### Planning
navigation

form Fields

examples

documentation


### Dr. Adnan Farooq

A newbie flutter/dart developer
