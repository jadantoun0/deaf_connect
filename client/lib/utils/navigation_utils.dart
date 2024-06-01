import 'package:flutter/material.dart';

class NavigationUtils {
  static void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pop(BuildContext context, {String? message}) {
    Navigator.pop(context, message);
  }
}
