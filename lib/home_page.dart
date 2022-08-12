import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_protector/device_built_in_auth.dart';
import 'package:password_protector/pin.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> _checkBiometrics() async {
    late bool canCheckBiometrics;
    late bool canAuthenticate;
    late bool authenticated;

    try {
      canCheckBiometrics = await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometrics = false;
    } catch (e) {
      canCheckBiometrics = false;
    }

    try {
      canAuthenticate = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      canAuthenticate = false;
    } catch (e) {
      canAuthenticate = false;
    }

    print([canCheckBiometrics, canAuthenticate]);

    if (canCheckBiometrics) {
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'Use device authentication',
          options: const AuthenticationOptions(
            stickyAuth: true,
          ),
        );
      } catch (e) {
        authenticated = false;
        print(e);
      }
    }

    return canCheckBiometrics || await auth.isDeviceSupported();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkBiometrics(),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Theme.of(context).colorScheme.background,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.data.toString() == "true") {
          return const BuiltInAuth();
        }

        return const UserPIN();
      }),
    );
  }
}

// class _HomePageState {
//   final LocalAuthentication auth = LocalAuthentication();
//   _SupportState _supportState = _SupportState.unknown;
//   bool _canCheckBiometrics = true;
//   List<BiometricType>? _availableBiometrics;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   auth.isDeviceSupported().then(
//   //         (bool isSupported) => setState(() => _supportState = isSupported
//   //             ? _SupportState.supported
//   //             : _SupportState.unsupported),
//   //       );
//   // }

//   Future<void> _getAvailableBiometrics() async {
//     late List<BiometricType> availableBiometrics;
//     try {
//       availableBiometrics = await auth.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       availableBiometrics = <BiometricType>[];
//       print(e);
//     }
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _availableBiometrics = availableBiometrics;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_supportState == _SupportState.unknown)
//               const CircularProgressIndicator()
//             else if (_supportState == _SupportState.supported)
//               const Text('This device is supported')
//             else
//               const Text('This device is not supported'),
//             const Divider(height: 100),
//             Text('Can check biometrics: $_canCheckBiometrics\n'),
//             ElevatedButton(
//               onPressed: _checkBiometrics,
//               child: const Text('Check biometrics'),
//             ),
//             const Divider(height: 100),
//             Text('Available biometrics: $_availableBiometrics\n'),
//             ElevatedButton(
//               onPressed: _getAvailableBiometrics,
//               child: const Text('Get available biometrics'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
