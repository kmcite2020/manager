// // ignore_for_file: overridden_fields

// part of 'manager.dart';

// class PersistableInjected<T> {
//   String? key;
//   T Function(Map<String, dynamic> json)? fromJson;
//   T Function() creator;
//   T? _state;
//   bool get persistable => key != null && fromJson != null;
//   PersistableInjected(
//     this.creator, {
//     this.key,
//     this.fromJson,
//   }) {
//     if (persistable) {
//       // readPersistentState();
//     } else {
//       throw 'Unexpected';
//     }
//   }

//   void readPersistentState() {
//     try {
//       final jsonString = box.get(key);
//       if (jsonString == null) {
//         // writePersistentState();
//         throw 'Error: State is not persisted yet';
//       }
//       final jsonMap = jsonDecode(jsonString);
//       final object = fromJson!(jsonMap);
//       state = object;
//     } catch (e) {
//       inform('Read: $e');
//     }
//   }

//   void writePersistentState() async {
//     try {
//       final jsonMap = toJson(state);
//       final jsonString = jsonEncode(jsonMap);
//       await box.put(key, jsonString);
//     } catch (e) {
//       inform('Write: $e');
//     }
//   }

//   T get state {
//     try {
//       // readPersistentState();
//       return _state!;
//     } catch (e) {
//       return creator();
//     }
//   }

//   set state(T t) {
//     // super.state = t;
//     if (persistable) {
//       writePersistentState();
//     }
//     state = t;
//   }

//   T call([T? t]) {
//     final result = call(t);
//     if (t != null && persistable) {
//       writePersistentState();
//     }
//     return result;
//   }

//   bool get loading => _state == null;

//   void reset() {
//     state = creator();
//   }

//   Widget build(Widget Function(T state) builder) => builder(state);
// }
