import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/password.dart';
import 'package:password_protector/pin.dart';
import 'package:password_protector/security_layers.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  DataHelper dataHelper = DataHelper();

  bool hasLoaded = false;
  bool usePIN = false;
  bool defaultIsPIN = false;
  bool requireBothPasswordAndPIN = false;
  bool usePassword = false;
  bool useBiometrics = false;
  String? password;
  // ignore: non_constant_identifier_names
  String? PIN;
  bool hasPIN = false;
  bool hasPassword = false;
  Set<String> messages = {};

  displayMessage(String type, BuildContext context) {
    // this prevents stacking messages when the user spams a button
    if (messages.contains(type)) return;
    messages.add(type);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1200),
        content: Text('Add a $type first!')));

    Future.delayed(const Duration(milliseconds: 1200))
        .then((_) => messages.remove(type));
  }

  @override
  void initState() {
    super.initState();
    Future.wait(
            [dataHelper.getSettings(), dataHelper.getUserDefinedPasswords()])
        .then((data) {
      Map<String, dynamic> settings = data[0];
      Map<String, dynamic> passwords = data[1];

      setState(() {
        hasLoaded = true;
        usePIN = settings["usePIN"];
        defaultIsPIN = settings["defaultIsPIN"];
        requireBothPasswordAndPIN = settings["requireBothPasswordAndPIN"];
        usePassword = settings["usePassword"];
        useBiometrics = settings["useBiometrics"];
        password = passwords["password"];
        PIN = passwords["PIN"];
        hasPIN = PIN?.isNotEmpty ?? false;
        hasPassword = password?.isNotEmpty ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(
              tooltip: "Lock",
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SecurityLayers(layerIndex: 0)),
                  (route) => false),
              icon: const Icon(Icons.lock_outline))
        ],
      ),
      body: !hasLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Preferrences'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        if (value) {
                          if (!hasPassword || !hasPIN) {
                            return displayMessage(
                                !hasPassword && !hasPIN
                                    ? 'PIN and a password'
                                    : !hasPassword
                                        ? 'password'
                                        : 'PIN',
                                context);
                          }
                          setState(() {
                            usePIN = true;
                            usePassword = true;
                          });
                          dataHelper.setSetting("usePIN", "true");
                          dataHelper.setSetting("usePassword", "true");
                        } else {}

                        setState(() {
                          requireBothPasswordAndPIN = value;
                        });
                        dataHelper.setSetting(
                            "requireBothPasswordAndPIN", value.toString());
                      },
                      initialValue: requireBothPasswordAndPIN,
                      leading: const Icon(Icons.security),
                      title: const Text('Use both PIN and password'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        setState(() {
                          defaultIsPIN = value;
                        });
                        dataHelper.setSetting("defaultIsPIN", value.toString());
                      },
                      initialValue: defaultIsPIN,
                      leading: const Icon(Icons.password),
                      title: const Text('Use PIN as default'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        if (value) {
                          if (!hasPIN) {
                            return displayMessage("PIN", context);
                          }
                        } else {
                          setState(() {
                            requireBothPasswordAndPIN = false;
                          });
                          dataHelper.setSetting(
                              "requireBothPasswordAndPIN", "false");
                        }

                        setState(() {
                          usePIN = value;
                        });
                        dataHelper.setSetting("usePIN", value.toString());
                      },
                      initialValue: usePIN,
                      leading: const Icon(Icons.pin),
                      title: const Text('Use PIN'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        if (value) {
                          if (!hasPassword) {
                            return displayMessage("password", context);
                          }
                        } else {
                          setState(() {
                            requireBothPasswordAndPIN = false;
                          });
                          dataHelper.setSetting(
                              "requireBothPasswordAndPIN", "false");
                        }

                        setState(() {
                          usePassword = value;
                        });
                        dataHelper.setSetting("usePassword", value.toString());
                      },
                      initialValue: usePassword,
                      leading: const Icon(Icons.abc),
                      title: const Text('Use Password'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        if (value) {
                          LocalAuthentication auth = LocalAuthentication();
                          bool canAuthenticate = false;
                          bool isSupported = false;

                          try {
                            canAuthenticate = await auth.canCheckBiometrics;
                            isSupported = await auth.isDeviceSupported();
                          } catch (_) {}

                          try {
                            auth.authenticate(
                              localizedReason: 'Use biometric authentication',
                            );
                            auth.stopAuthentication();
                          } on PlatformException catch (_) {
                            canAuthenticate = false;
                          } catch (e) {
                            canAuthenticate = false;
                          }

                          if (!isSupported || !canAuthenticate) {
                            if (mounted) {
                              return displayMessage(
                                  "Biometrics (PIN/Password/Fingerprint/Face) to your device",
                                  context);
                            }
                          }
                        }

                        setState(() {
                          useBiometrics = value;
                        });
                        dataHelper.setSetting(
                            "useBiometrics", value.toString());
                      },
                      initialValue: useBiometrics,
                      leading: const Icon(Icons.fingerprint_outlined),
                      title: const Text('Use Biometrics'),
                    ),
                  ],
                ),
                SettingsSection(
                    title: const Text("Passwords"),
                    tiles: <SettingsTile>[
                      SettingsTile.navigation(
                        title: Text(
                            "${password == null ? "Set" : "Change"} Password"),
                        leading: const Icon(Icons.abc),
                        onPressed: ((context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SetPassword(),
                            ))),
                      ),
                      SettingsTile.navigation(
                        title: Text("${PIN == null ? "Set" : "Change"} PIN"),
                        leading: const Icon(Icons.pin),
                        onPressed: ((context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SetPIN(),
                            ))),
                      )
                    ])
              ],
            ),
    ));
  }
}
