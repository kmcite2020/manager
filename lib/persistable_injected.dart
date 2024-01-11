// ignore_for_file: overridden_fields

part of 'manager.dart';

class PersistableInjected<T> extends Injected<T> {
  String? key;
  T Function(Map<String, dynamic> json)? fromJson;
  T Function() creator;
  @override
  T? _state;
  bool get persistable => key != null && fromJson != null;
  PersistableInjected(
    this.creator, {
    this.key,
    this.fromJson,
  }) {
    if (persistable) {
      readPersistentState();
    } else if (key == null) {
      throw 'Invalid key';
    } else if (fromJson == null) {
      throw 'Invalid fromJson';
    } else {
      throw 'Unexpected';
    }
  }

  void readPersistentState() {
    try {
      final jsonString = box.get(key);
      if (jsonString == null) {}
      final jsonMap = jsonDecode(jsonString);
      final object = fromJson!(jsonMap);
      state = object;
    } catch (e) {
      inform(e.toString());
    }
  }

  void writePersistentState() async {
    try {
      final jsonMap = toJson(state);
      final jsonString = jsonEncode(jsonMap);
      await box.put(key, jsonString);
    } catch (e) {
      inform(e.toString());
    }
  }

  @override
  set state(T t) {
    super.state = t;
    if (persistable) {
      writePersistentState();
    }
  }

  @override
  T call([T? t]) {
    final result = super.call(t);
    if (t != null && persistable) {
      writePersistentState();
    }
    return result;
  }

  @override
  bool get loading => _state == null;

  @override
  void reset() {
    state = creator();
  }

  @override
  Widget build(Widget Function(T state) builder) => builder(state);
}
