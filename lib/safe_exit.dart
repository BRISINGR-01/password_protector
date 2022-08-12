import 'package:flutter/material.dart';

class SafeExit extends StatefulWidget {
  final Widget child;
  const SafeExit({Key? key, required this.child}) : super(key: key);

  @override
  State<SafeExit> createState() => _SafeExitState();
}

class _SafeExitState extends State<SafeExit> with WidgetsBindingObserver {
  AppLifecycleState appLifecycleState = AppLifecycleState.detached;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _backToAuth() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _backToAuth();
        break;
      case AppLifecycleState.inactive:
        _backToAuth();
        break;
      case AppLifecycleState.paused:
        _backToAuth();
        break;
      case AppLifecycleState.detached:
        _backToAuth();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
