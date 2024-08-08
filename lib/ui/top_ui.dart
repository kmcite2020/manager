import 'package:flutter/material.dart';

import 'ui.dart';

abstract class TopUI extends UI {
  Widget home(BuildContext context);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home(context),
      theme: ThemeData.dark(useMaterial3: false),
    );
  }
}
