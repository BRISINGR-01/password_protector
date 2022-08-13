// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_protector/app.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/device_built_in_auth.dart';
import 'package:password_protector/password.dart';
import 'package:password_protector/pin.dart';

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

          if (settings["order"].length <= layerIndex) return const App();

          switch (settings["order"][layerIndex]) {
            case SecurityElements.Biometric:
              if (data["canAuthenticate"]) {
                return BuiltInAuth(layerIndex: layerIndex);
              } else {
                return SecurityLayers(layerIndex: layerIndex + 1);
              }
            case SecurityElements.PIN:
              return UserPIN(layerIndex: layerIndex);
            case SecurityElements.Password:
              return UserPassword(layerIndex: layerIndex);
            case SecurityElements.AllUserDefined:
              if (data["settings"]["usePIN"] &&
                  data["settings"]["preferredMethod"] == SecurityElements.PIN &&
                  passwords.containsKey("PIN")) {
                return UserPIN(layerIndex: layerIndex);
              } else if (data["settings"]["usePassword"] &&
                  data["settings"]["preferredMethod"] ==
                      SecurityElements.Password &&
                  passwords.containsKey("password")) {
                return UserPassword(layerIndex: layerIndex);
              } else if (passwords.isNotEmpty) {
                Widget child;
                if (passwords.containsKey("PIN") &&
                    settings["preferredMethod"] == SecurityElements.PIN) {
                  child = UserPIN(layerIndex: layerIndex);
                } else if (passwords.containsKey("password") &&
                    settings["preferredMethod"] == SecurityElements.Password) {
                  child = UserPassword(layerIndex: layerIndex);
                } else if (passwords.containsKey("PIN")) {
                  child = UserPIN(layerIndex: layerIndex);
                } else if (passwords.containsKey("password")) {
                  child = UserPassword(layerIndex: layerIndex);
                } else {
                  child = const App();
                }

                return ErrorDisplay(child: child);
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
  const ErrorDisplay({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "There was a problem with the PIN/Password. Please renew them!")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: widget.child);
  }
}
