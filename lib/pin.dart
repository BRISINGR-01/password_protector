import 'package:flutter/material.dart';
import 'package:flutter_pin_code_widget/flutter_pin_code_widget.dart';
import 'package:password_protector/app.dart';
import 'package:password_protector/password.dart';

class UserPIN extends StatefulWidget {
  const UserPIN({Key? key}) : super(key: key);

  @override
  State<UserPIN> createState() => _UserPINState();
}

class _UserPINState extends State<UserPIN> {
  Color? pinInputColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Pin code'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: const [
                  Text(
                    'Enter the PIN you have chosen for this app',
                    textAlign: TextAlign.center,
                  ),
                  Text('Forgot my PIN?')
                ],
              ),
            ),
            const SizedBox(height: 60),
            Expanded(
              child: PinCodeWidget(
                  onFullPin: (String pin, __) async {
                    if (pin == "1212") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => App(),
                          ));
                    } else {
                      await Future.delayed(const Duration(milliseconds: 100));

                      setState(() {
                        pinInputColor = Theme.of(context).colorScheme.error;
                      });

                      await Future.delayed(const Duration(milliseconds: 400));

                      if (!mounted) return;

                      setState(() {
                        pinInputColor = null;
                      });
                    }
                  },
                  initialPinLength: 4,
                  onChangedPin: (_) {},
                  emptyIndicatorColor:
                      pinInputColor ?? Theme.of(context).colorScheme.primary,
                  filledIndicatorColor: Colors.blue.shade300,
                  // pinInputColor ?? Theme.of(context).colorScheme.tertiary,
                  onPressColorAnimation: Colors.white,
                  buttonColor: Theme.of(context).colorScheme.primary,
                  numbersStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30),
                  deleteButtonColor: Theme.of(context).colorScheme.primary,
                  leftBottomWidget: Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserPassword(),
                            ));
                      },
                      child: const Icon(
                        Icons.swap_horiz,
                        size: 30,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
