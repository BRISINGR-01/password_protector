// ignore_for_file: constant_identifier_names

class DataHelper {
  DataHelper();

  getSettings() async {
    Map<String, dynamic> settings = {
      "useBiometric": true,
      "usePIN": true,
      "usePassword": true,
      "preferredMethod": SecurityElements.Password,
      "order": [SecurityElements.Biometric, SecurityElements.AllUserDefined]
    };

    return settings;
  }

  setSettings() async {}

  getUserDefinedPasswords() async {
    Map<String, String> passwords = {"password": "asd", "PIN": "1212"};

    return passwords;
  }

  setUserDefinedPassword() async {}

  getUserData() {}

  setUserData() {}
}

enum SecurityElements {
  Biometric,
  PIN,
  Password,
  AllUserDefined,
}
