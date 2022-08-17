import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/security_layers.dart';

class BuiltInAuth extends StatefulWidget {
  final int layerIndex;
  const BuiltInAuth({Key? key, required this.layerIndex}) : super(key: key);

  @override
  State<BuiltInAuth> createState() => _BuiltInAuthState();
}

class _BuiltInAuthState extends State<BuiltInAuth> {
  late bool authenticated;
  final LocalAuthentication auth = LocalAuthentication();
  DataHelper dataHelper = DataHelper();

  _authenticate() async {
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Use device authentication',
        options: const AuthenticationOptions(
            stickyAuth: true, sensitiveTransaction: true),
      );
    } on PlatformException catch (e) {
      if (e.message == "Required security features not enabled") {
        dataHelper.setSetting("useBiometrics", "false");
        authenticated = true;
      } else {
        authenticated = false;
      }
    } catch (e) {
      authenticated = false;
    }

    if (!mounted) return;

    if (authenticated) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecurityLayers(
              layerIndex: widget.layerIndex + 1,
            ),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: _authenticate,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(80.0),
                child: Text(
                    'Please authenticate using the device biometric security',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18.0),
                  child: Icon(
                    Icons.perm_device_information,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
