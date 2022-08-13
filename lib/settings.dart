import 'package:flutter/material.dart';
import 'package:password_protector/safe_exit.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeExit(
        child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          actions: [
            IconButton(
                tooltip: "Lock",
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.lock_outline))
          ],
        ),
        body: const Text(""),
      ),
    ));
  }
}
