# manager
A new Global State Manager.
## Bussiness Logic & State Management
You can create Models that are reactive and modifiable and react to changes in other objects. Also UI of the app reacts to it.
`UI` is an `abstract` class that is to be extended in order to let the User Interface of the app build automatically in response to changes in Models.
The preferred method to create Models is using freezed models which support immutability.
This is a simple class, we will use it to create Reactive Models. 
```dart
class Model {
  final int value;
  const Model(this.value);
  int call() => value;
}
```
```dart
/// Create a Injected State
final modelRM = RM.create(()=> Model(0));
/// Use the getter in UI, you can use the _RM directly in Widgets.
int get counter => modelRM()();
/// Use this setter in callbacks to modify the Injected State.
set counter(int value)=> modelRM(Model(value));
```
<!-- <p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/master/assets/Logo-Black.png" width="570" alt=''/>
</p> -->
A new Global State Manager.

## Why Global State Manager?
### What is Global State Manager
GSM -> Global State Manager is reactive state management solution. It offers Global state, simplicity and ease of development, state persistence and much more.

### Motivation
Modern applications rarely come with all the information necessary to render their User Interface. Instead, the data is often fetched asynchronously from a server.

The problem is, working with asynchronous code is hard. Although Flutter comes with some way to create state variables and refresh the UI on change, it is still fairly limited. A number of challenges remain unsolved:

Asynchronous requests need to be cached locally, as it would be unreasonable to re-execute them whenever the UI updates.
Since we have a cache, our cache could get out of date if we're not careful.
We also need to handle errors and loading states
Nailing those problems at scale can be difficult, and they are impacted by a large amount of features, such as:

#### pull to refresh

#### infinite lists / fetch as we scroll

#### search as we type

#### debouncing asynchronous requests

#### cancelling asynchronous requests when no-longer used

#### optimistic UIs

#### offline mode

These features can be tricky to implement, but are crucial for a good user experience. Yet few packages try to tackle those problems directly, and a lot of the work has to be done manually. That's where Global State Manager comes in. Global State Manager tries to solve those problems, by offering a new unique way of writing business logic, inspired by Flutter widgets. In many ways Global State Manager is comparable to widgets, but for state. Using this new approach, these complex features are mostly done by default. All that's left is to focus on your UI. Skeptical? Here's an example. The following snippet is a simplification of the pub.dev client application implemented using Global State Manager.
```dart
// Fetches the list of packages from pub.dev
Future<List<Package>> fetchPackages(
  FetchPackagesRef ref, {
  required int page,
  String search = '',
}) async {
  final dio = Dio();
  // Fetch an API. Here we're using package:dio, but we could use anything else.
  final response = await dio.get<List<Object?>>(
    'https://pub.dartlang.org/api/search?page=$page&q=${Uri.encodeQueryComponent(search)}',
  );

  // Decode the JSON response into a Dart class.
  return response.data?.map(Package.fromJson).toList() ?? const [];
}
``` 
### No boilerplate
The specificity of `Global State Manager` is that it has practically no boilerplate.
## Get Started
Heavily inspired from States_Rebuilder library.
### Installing the package
```yaml
manager:
    git: https://github.com/kmcite2020/manager
```
### Usage Example

## Making RMs / Network Requests -> GET
### Defining the Model
use the freezed, build_runner, json_serializable, and annotations
```dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// The response of the `GET /api/activity` endpoint.
///
/// It is defined using `freezed` and `json_serializable`.
@freezed
class Activity with _$Activity {
  factory Activity({
    required String key,
    required String activity,
    required String type,
    required int participants,
    required double price,
  }) = _Activity;

  /// Convert a JSON object into an [Activity] instance.
  /// This enables type-safe reading of the API response.
  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
```
### Creating the RM
simple functions to create RMs
```dart
final functionRM = RM.future(
  () {
    /// future-based logic here;
  },
);
final createdRM = RM.create(
  () {
    /// your logic here;
  },
);
final streamRM = RM.stream(
  () {
    /// stream based reactive logic here;
  },
);
```
### Rendering the network request's response in the UI
use these final variables to build UI
```dart

/// This will create a RM named `activityRM`
/// which will cache the result of this function.

final activityRM = RM.future(
  () async {
    // Using package:http, we fetch a random activity from the Bored API.
    final response = await http.get(Uri.https('boredapi.com', '/api/activity'));
    // Using dart:convert, we then decode the JSON payload into a Map data structure.
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    // Finally, we convert the Map into an Activity instance.
    return Activity.fromJson(json);
  },
);

```
In UI you can show using the build method of RM or you can use UI abstract class to listen to any RM state.

You can use `loading` getter of RM to check if its loading the future or stream.

```dart

/// The homepage of our application
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (activityRM.loading)
          CircularProgressIndicator()
        else
          activityRM.build(
            (state) => state.text(),
          ),
      ],
    );
  }
}

// OR
class Home extends UI {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        activityRM().text(), // Using callable class its easy to get underlying data        
        activityRM.build(
          (state) {
            return state.text();
          },
        ),
      ],
    );
  }
}
```
## Performing Side Effects -> POST
by using the callable class features it is very easy to post mutations in state
### Defining an RM
create a final variable with RM and its constructors i.e create(), stream(), future().
```dart
final RM<List<Todo>> todoListRM = RM.future(
  () async => [
    Todo(description: 'Learn Flutter', completed: true),
    Todo(description: 'Learn Dart'),
    Todo(description: 'Learn Global State Manager'),
  ],
);
```
### Exposing a method to perform a POST request
```dart
Future<void> addTodo(Todo todo) {
  final list = todoListRM();
  todoListRM(List.of(list)..add(todo));
}
```
### Using UI
```dart
class Example extends UI {
  const Example({super.key});

  @override
  Widget build(context) {
    return ElevatedButton(
      onPressed: () {
        addTodo(Todo(description: 'This is a new todo'));
      },
      child: const Text('Add Todo'),
    );
  }
}
```
by using methods to modify / post the state
we created addTodo(Todo todo) method to modify the state.
## Passing arguments to your requests
...coming soon...
### Updating our RMs to accept arguments
...coming soon...
...coming soon...
### Updating our UI to pass arguments
...coming soon...
...coming soon...
### Caching consideration and parameter restrictions
...coming soon...
...coming soon...
## Websockets and synchronous execution
...coming soon...
### Synchronously returning an Object
...coming soon...
...coming soon...
### Listening to Stream
...coming soon...
...coming soon...

### Disabling conversion of Stream/Future to AsyncValue
...coming soon...
## Clearing Cache and Reacting to State Disposal
...coming soon...
## Eager initialization of providers
...coming soon...
## Testing your RMs
...coming soon...
## Optimizing performance
...coming soon...
### Filtering widget/provider rebuild using "select".
### Selecting asynchronous properties

## Favourite Packages
`build_runner`
`json_annotation`
`json_serializable`
`freezed`
`freezed_annotation`

```text
If a Model class is generated by freezed and is serializable then it can be persisted.
1. Create a generated Model
2. Create an RM for the Model
3. Provide freezedSave() configuration
4. Enable persistance from RM.enablePersistance() in main method.
5. Then modify the state and it will be persisted across app restarts.
```
`hive_flutter` is used under the hood.
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
