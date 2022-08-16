// ignore_for_file: constant_identifier_names
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataHelper {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  DataHelper();

  Future<Map<String, dynamic>> getSettings() async {
    Map<String, String> allValues = await storage.readAll();
    // storage.delete(key: "PIN");
    // storage.delete(key: "password");

    Map<String, dynamic> settings = {
      "useBiometrics": allValues["useBiometrics"] == "true",
      "usePIN": allValues["usePIN"] == "true",
      "usePassword": allValues["usePassword"] == "true",
      "defaultIsPIN": allValues["defaultIsPIN"] != "false",
      "requireBothPasswordAndPIN":
          allValues["requireBothPasswordAndPIN"] == "true",
    };

    return settings;
  }

  setSetting(String key, String value) {
    storage.write(key: key, value: value);
  }

  Future<Map<String, String>> getUserDefinedPasswords() async {
    String? password = await storage.read(key: "password");
    // ignore: non_constant_identifier_names
    String? PIN = await storage.read(key: "PIN");

    Map<String, String> passwords = {
      if (password != null) "password": password,
      if (PIN != null) "PIN": PIN,
    };

    return passwords;
  }

  Future<List<Map<String, String>>> getUserData() async {
    String data = await storage.read(key: "userData") ?? "[]";

    return List.from(json.decode(data))
        .map((e) => ({
              "name": e["name"] as String,
              "value": e["value"] as String,
            }))
        .toList();
  }

  setUserData(List<Map<String, String>> data) {
    storage.write(key: "userData", value: json.encode(data));
  }
}
