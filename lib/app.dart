import 'package:flutter/material.dart';
import 'package:password_protector/safe_exit.dart';
import 'package:password_protector/settings.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return SafeExit(
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: const Text("Passwords"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                tooltip: "Go to Settings",
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Settings(),
                    )),
                icon: const Icon(Icons.settings)),
            IconButton(
                tooltip: "Lock",
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.lock_outline))
          ],
        ),
        body: const Center(child: Text("Secrets")),
      )),
    );
  }
}
