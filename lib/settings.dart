import 'package:flutter/material.dart';
import 'package:password_protector/app.dart';
import 'package:password_protector/data.dart';
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

  @override
  void initState() {
    super.initState();
    dataHelper.getSettings().then((value) => setState(() {
          hasLoaded = true;
          usePIN = value["usePIN"];
          defaultIsPIN = value["defaultIsPIN"];
          requireBothPasswordAndPIN = value["requireBothPasswordAndPIN"];
          usePassword = value["usePassword"];
          useBiometrics = value["useBiometrics"];
        }));
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
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.lock_outline))
        ],
      ),
      bottomSheet: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "You may need to restart the app in order for the changes to take place",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
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
                        if (value) {
                        } else {}

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
                        } else {}

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
                        } else {}

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
                      onToggle: (value) {
                        if (value) {
                        } else {}

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
                        title: const Text("Change Password"),
                        leading: const Icon(Icons.abc),
                        onPressed: ((context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const App(),
                            ))),
                      ),
                      SettingsTile.navigation(
                        title: const Text("Change PIN"),
                        leading: const Icon(Icons.pin),
                        onPressed: ((context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const App(),
                            ))),
                      )
                    ])
              ],
            ),
    ));
  }
}
