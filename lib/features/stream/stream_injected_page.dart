import 'package:flutter/material.dart';
import 'package:manager/main.dart';
import 'package:manager/manager.dart';

class StreamInjectedPage extends UI {
  const StreamInjectedPage({super.key});
  @override
  void dispose() {
    streamRM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'StreamInjected<T>'.text(),
      ),
      body: Column(
        children: [
          'loading: ${streamRM.loading}'.text(),
          'runtimeType: ${streamRM.runtimeType}'.text(),
          'hashCode: ${streamRM.hashCode}'.text(),
          'value: ${streamRM.loading ? streamRM.initialState : streamRM.state}'
              .text(),
          streamRM.build(
            (state) => state.text(),
          ),
        ].map(
          (_) {
            return _.pad();
          },
        ).toList(),
      ),
    );
  }
}

final streamRM = StreamInjected(
  () => Stream.periodic(
    const Duration(
      seconds: 1,
    ),
    (_) => _,
  ),
);
