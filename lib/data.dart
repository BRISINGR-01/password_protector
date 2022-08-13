// ignore_for_file: constant_identifier_names
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataHelper {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  DataHelper();

  Future<Map<String, dynamic>> getSettings() async {
    Map<String, String> allValues = await storage.readAll();
    // print(await storage.readAll());
    // Map<String, String> allValues = {
    //   "useBiometrics": "false",
    //   "usePIN": "false",
    //   "usePassword": "false",
    //   "preferredMethod": "false",
    //   "order": "[\"Biometric\"]"
    // };

    Map<String, dynamic> settings = {
      "useBiometrics": allValues["useBiometrics"] == "true",
      "usePIN": allValues["usePIN"] == "true",
      "usePassword": allValues["usePassword"] == "true",
      "defaultIsPIN": allValues["defaultIsPIN"] == "true",
      "requireBothPasswordAndPIN":
          allValues["requireBothPasswordAndPIN"] == "true",
    };

    return settings;
  }

  setSetting(String key, String value) {
    storage.write(key: key, value: value);
  }

  getUserDefinedPasswords() async {
    Map<String, String> passwords = {"password": "asd", "PIN": "1212"};

    return passwords;
  }

  setUserDefinedPassword() async {}

  getUserData() {}

  setUserData() {}
}

Set securityElements = {
  "Biometric",
  "PIN",
  "Password",
  "AllUserDefined",
};
