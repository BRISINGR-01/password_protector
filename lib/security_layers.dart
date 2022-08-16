// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_protector/app.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/device_built_in_auth.dart';
import 'package:password_protector/password.dart';
import 'package:password_protector/pin.dart';
import 'package:password_protector/settings.dart';

class SecurityLayers extends StatelessWidget {
  final int layerIndex;
  SecurityLayers({Key? key, required this.layerIndex}) : super(key: key);

  final LocalAuthentication auth = LocalAuthentication();
  final DataHelper dataHelper = DataHelper();

  _canAuthenticate() async {
    late bool canCheckBiometrics;

    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometrics = false;
    } catch (e) {
      canCheckBiometrics = false;
    }

    return canCheckBiometrics || await auth.isDeviceSupported();
  }

  _getData() async {
    Map<String, dynamic> settings = await dataHelper.getSettings();

    Map<String, String> passwords = await dataHelper.getUserDefinedPasswords();

    bool canAuthenticate = await _canAuthenticate();

    return ({
      "canAuthenticate": canAuthenticate,
      "passwords": passwords,
      "settings": settings
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getData(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return SafeArea(
              child: Scaffold(
                  appBar: AppBar(),
                  body: const Center(child: CircularProgressIndicator())),
            );
          }

          Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
          Map<String, dynamic> settings = data["settings"];
          Map<String, String> passwords = data["passwords"];

          switch (layerIndex) {
            case 0:
              if (data["canAuthenticate"] && settings["useBiometrics"]) {
                return BuiltInAuth(layerIndex: layerIndex);
              } else if (passwords.isEmpty) {
                return const App();
              } else if (!settings["usePIN"] && !settings["usePassword"]) {
                return const App();
              } else {
                return SecurityLayers(layerIndex: 1);
              }
            case 1:
              if (settings["requireBothPasswordAndPIN"]) {
                if (passwords.containsKey("PIN")) {
                  return UserPIN(
                    layerIndex: layerIndex,
                    enableSwitching: false,
                    passwords: passwords,
                  );
                }

                if (passwords.containsKey("password")) {
                  return ErrorDisplay(
                    message:
                        "There is a problem with you PIN! Please renew it!",
                    child: UserPassword(
                      layerIndex: layerIndex,
                      enableSwitching: false,
                      passwords: passwords,
                    ),
                  );
                }
              }

              if (settings["defaultIsPIN"]) {
                if (settings["usePIN"] && passwords.containsKey("PIN")) {
                  return UserPIN(
                    layerIndex: layerIndex,
                    enableSwitching: passwords.containsKey("password") &&
                        settings["usePassword"],
                    passwords: passwords,
                  );
                } else if (settings["usePassword"] &&
                    passwords.containsKey("password")) {
                  return UserPassword(
                    layerIndex: layerIndex,
                    enableSwitching: false,
                    passwords: passwords,
                  );
                }
              } else {
                if (settings["usePassword"] &&
                    passwords.containsKey("password")) {
                  return UserPassword(
                    layerIndex: layerIndex,
                    enableSwitching:
                        passwords.containsKey("PIN") && settings["usePIN"],
                    passwords: passwords,
                  );
                } else if (settings["usePIN"] && passwords.containsKey("PIN")) {
                  return UserPIN(
                    layerIndex: layerIndex,
                    enableSwitching: false,
                    passwords: passwords,
                  );
                }
              }

              return const App();
            case 2:
              if (settings["requireBothPasswordAndPIN"]) {
                if (!passwords.containsKey("PIN")) return const App();
                if (passwords.containsKey("password")) {
                  return UserPassword(
                    layerIndex: layerIndex,
                    enableSwitching: false,
                    passwords: passwords,
                  );
                }
              }

              return const App();
            default:
              return const App();
          }
        }));
  }
}

class ErrorDisplay extends StatefulWidget {
  final Widget child;
  final String message;
  const ErrorDisplay({Key? key, required this.child, required this.message})
      : super(key: key);

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.message)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: widget.child);
  }
}

class AccessDenied extends StatelessWidget {
  const AccessDenied({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
      body: Center(child: Text("Access Denied!")),
    ));
  }
}
