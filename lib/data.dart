// ignore_for_file: constant_identifier_names
import 'dart:convert';

import 'package:flutter_keychain/flutter_keychain.dart';

class DataHelper {
  DataHelper();

  Future<Map<String, dynamic>> getSettings() async {
    Map<String, dynamic> settings = {
      "useBiometrics":
          await FlutterKeychain.get(key: "useBiometrics") == "true",
      "usePIN": await FlutterKeychain.get(key: "usePIN") == "true",
      "usePassword": await FlutterKeychain.get(key: "usePassword") == "true",
      "defaultIsPIN": await FlutterKeychain.get(key: "defaultIsPIN") != "false",
      "requireBothPasswordAndPIN":
          await FlutterKeychain.get(key: "requireBothPasswordAndPIN") == "true",
    };

    return settings;
  }

  setSetting(String key, String value) {
    FlutterKeychain.put(key: key, value: value);
  }

  Future<Map<String, String>> getUserDefinedPasswords() async {
    String? password = await FlutterKeychain.get(key: "password");
    // ignore: non_constant_identifier_names
    String? PIN = await FlutterKeychain.get(key: "PIN");

    Map<String, String> passwords = {
      if (password != null) "password": password,
      if (PIN != null) "PIN": PIN,
    };

    return passwords;
  }

  Future<List<Map<String, String>>> getUserData() async {
    String data = await FlutterKeychain.get(key: "userData") ?? "[]";

    return List.from(json.decode(data))
        .map((e) => ({
              "name": e["name"] as String,
              "value": e["value"] as String,
            }))
        .toList();
  }

  setUserData(List<Map<String, String>> data) {
    FlutterKeychain.put(key: "userData", value: json.encode(data));
  }
}
