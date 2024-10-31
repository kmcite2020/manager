import 'manager.dart';

export 'architectures/redux.dart' show Global, Local, Action, Middleware;
export 'dart:async';
export 'dart:convert';
export 'hive_storage.dart' show HiveStorage;
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart' hide Action;
export 'package:flutter_native_splash/flutter_native_splash.dart';
export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:manager/architectures/bloc.dart';
export 'package:manager/architectures/riverpod.dart';
export 'package:manager/architectures/spark.dart';
export 'package:manager/extensions.dart';
export 'package:manager/navigation.dart';
export 'package:manager/ui/top_ui.dart';
export 'package:manager/ui/ui.dart';
export 'package:objectbox/objectbox.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:path/path.dart';
export 'package:path_provider/path_provider.dart';
export 'package:states_rebuilder/states_rebuilder.dart';
export 'package:uuid/uuid.dart';
export 'ui/app_ui.dart' show ImperativeUI, DeclarativeUI;

/// Provides a set of utility functions and types for working with the ObjectBox database and other common Flutter packages.
///
/// The `box<T>` function returns an ObjectBox `Box` instance for the given type `T`.
///
/// The `_finder<T>` function is a helper that returns a list of items from an ObjectBox `Query<T>`.
///
/// The `rm<T>` function injects a stream of `List<T>` items from an ObjectBox `Box` using the `states_rebuilder` package.
///
/// The `list<T>` function is a helper that returns a modifier function for adding items to an ObjectBox `Box` and retrieving the current list of items.
///
/// The `MaterialColorConverter` and `Uint8ListConverter` classes provide custom JSON converters for `MaterialColor` and `Uint8List` types, respectively.
///
/// The `navigator` constant provides a reference to the `RM.navigate` function from the `states_rebuilder` package.
///
/// The `UI` type alias refers to the `ReactiveStatelessWidget` type from the `states_rebuilder` package.

Box<T> box<T>(store) => store.box<T>();
List<T> _finder<T>(Query<T> query) => query.find();

/// Injects a stream of `List<T>` items from an ObjectBox `Box` using the `states_rebuilder` package.
///
/// The `rm<T>` function returns an `Injected<List<T>>` instance that provides a stream of the current list of items stored in the `Box<T>`. The stream is updated whenever the contents of the `Box<T>` change.
///
/// The `initialState` parameter is used to provide an initial value for the stream, which is set to an empty list `<T>[]`.
///
/// The `box.query().watch(triggerImmediately: true)` call sets up a watch on the `Box<T>` that triggers the stream to emit the current list of items immediately, and then updates the stream whenever the contents of the `Box<T>` change.
///
/// The `_finder<T>` function is used to convert the `Query<T>` result into a `List<T>`.
Injected<List<T>> rm<T>(Box<T> box) {
  return RM.injectStream(
    () => box.query().watch(triggerImmediately: true).map(_finder),
    initialState: <T>[],
  );
}

List<T> Function([T? item]) list<T>(Box<T> box, Injected<List<T>> rm) {
  return ([item]) {
    if (item != null) box.put(item);
    return rm.state;
  };
}

/// A type alias for a function that takes an optional `T` parameter and returns a `T`.
/// This is commonly used as a modifier function that can optionally update and return a new instance of `T`.
typedef Modifier<T> = T Function([T?]);

final navigator = RM.navigate;

typedef UI = ReactiveStatelessWidget;

class MaterialColorConverter implements JsonConverter<MaterialColor, int> {
  const MaterialColorConverter();

  @override
  MaterialColor fromJson(int json) => Colors.primaries[json];

  @override
  int toJson(MaterialColor object) => Colors.primaries.indexOf(object);
}

/// Provides a custom JSON converter for converting between `Uint8List` and `String` types.
///
/// The `fromJson` method decodes a base64-encoded `String` to a `Uint8List`.
/// The `toJson` method encodes a `Uint8List` to a base64-encoded `String`.
class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}

///
/// before importing this package make sure you have all the following
/// packages installed.
///
/// hive_flutter: ^1.1.0
/// uuid: ^4.4.0
/// package_info_plus: ^8.0.0
/// path_provider: ^2.1.3
/// states_rebuilder: ^6.4.0
/// objectbox_generator: ^4.0.3
/// objectbox_flutter_libs: ^4.0.3
/// objectbox: ^4.0.3
/// json_annotation:
/// json_serializable:
/// freezed:
/// freezed_annotation:
/// flutter_native_splash:
