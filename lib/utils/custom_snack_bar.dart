import 'package:flutter/material.dart';

class SnackbarServices {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();


   void showSnackBar(dynamic message, Color color) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}

