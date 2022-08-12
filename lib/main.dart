// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_protector/home_page.dart';

void main() {
  Color primary = Colors.blueGrey.shade300;
  Color tertiary = Color.fromARGB(255, 91, 255, 21);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: primary.withAlpha(180),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: primary,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
      fontFamily: "New Times Roman",
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: tertiary,
        onSecondary: Colors.black,
        tertiary: tertiary,
        onTertiary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: Colors.grey.shade100,
        onBackground: Colors.black,
        surface: Colors.grey.shade200,
        onSurface: Colors.black,
      ),
    ),
    debugShowCheckedModeBanner: false,
  ));
}
