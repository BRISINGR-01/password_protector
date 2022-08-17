import 'package:flutter/material.dart';
import 'package:flutter_pin_code_widget/flutter_pin_code_widget.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/password.dart';
import 'package:password_protector/safe_exit.dart';
import 'package:password_protector/security_layers.dart';
import 'package:password_protector/settings.dart';

class UserPIN extends StatefulWidget {
  final int layerIndex;
  final bool enableSwitching;
  final Map<String, String> passwords;
  const UserPIN(
      {Key? key,
      required this.layerIndex,
      required this.enableSwitching,
      required this.passwords})
      : super(key: key);

  @override
  State<UserPIN> createState() => _UserPINState();
}

class _UserPINState extends State<UserPIN> {
  Color? pinInputColor;

  @override
  Widget build(BuildContext context) {
    return SafeExit(
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: const Text('PIN code'),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Enter the PIN you have chosen for this app',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
            Expanded(
              child: PinCodeWidget(
                  onFullPin: (String pin, __) async {
                    if (pin == widget.passwords["PIN"]) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecurityLayers(
                                layerIndex: widget.layerIndex + 1),
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
                  initialPinLength: widget.passwords["PIN"]?.length ?? 4,
                  onChangedPin: (_) {},
                  emptyIndicatorColor:
                      pinInputColor ?? Theme.of(context).colorScheme.primary,
                  filledIndicatorColor: Colors.blue.shade300,
                  onPressColorAnimation: Colors.white,
                  buttonColor: Theme.of(context).colorScheme.primary,
                  numbersStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30),
                  deleteButtonColor: Theme.of(context).colorScheme.primary,
                  leftBottomWidget: !widget.enableSwitching
                      ? Container()
                      : Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserPassword(
                                      layerIndex: widget.layerIndex,
                                      enableSwitching: widget.enableSwitching,
                                      passwords: widget.passwords,
                                    ),
                                  ));
                            },
                            child: const Icon(
                              Icons.swap_horiz,
                            ),
                          ),
                        )),
            ),
          ],
        ),
      )),
    );
  }
}

class SetPIN extends StatefulWidget {
  const SetPIN({Key? key}) : super(key: key);

  @override
  State<SetPIN> createState() => _SetPINState();
}

class _SetPINState extends State<SetPIN> {
  final DataHelper dataHelper = DataHelper();
  String state = "first PIN";
  PinCodeState? widgetState;
  String firstEnteredPIN = "";
  String currentPIN = "";

  @override
  Widget build(BuildContext context) {
    return SafeExit(
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: const Text('Set PIN code'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              state == "first PIN"
                  ? 'Enter PIN'
                  : state == "repeating"
                      ? 'Repeat PIN'
                      : "Wrong PIN",
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 60),
            Expanded(
              child: PinCodeWidget(
                  onFullPin: (String pin, newWidgetState) async {
                    if (state == "first PIN") {
                      newWidgetState.changePinLength(currentPIN.length + 1);
                      newWidgetState.pin = pin;
                      setState(() {
                        widgetState = newWidgetState;
                      });
                    } else if (state == "repeating") {
                      if (currentPIN == firstEnteredPIN) {
                        dataHelper.setSetting("PIN", pin);
                        dataHelper.setSetting("usePIN", "true");
                        dataHelper.setSetting("defaultIsPIN", "true");

                        Navigator.pop(context); // remove the `Set PIN` route
                        Navigator.pop(context); // remove the `Settings` route
                        Navigator.push(
                            // add the `Settings` route so that the values are refreshed
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Settings(),
                            ));
                      } else {
                        setState(() {
                          state = "wrong";
                          firstEnteredPIN = "";
                        });

                        Future.delayed(const Duration(milliseconds: 800))
                            .then((_) => setState((() {
                                  state = "first PIN";
                                })));
                      }
                    }
                  },
                  initialPinLength: 4,
                  onChangedPin: (pin) {
                    setState(() {
                      currentPIN = pin;
                    });
                  },
                  emptyIndicatorColor: state == "wrong"
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  filledIndicatorColor: Colors.blue.shade300,
                  onPressColorAnimation: Colors.white,
                  buttonColor: Theme.of(context).colorScheme.primary,
                  numbersStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30),
                  deleteButtonColor: Theme.of(context).colorScheme.primary,
                  leftBottomWidget: widgetState == null || state != "first PIN"
                      ? Container()
                      : Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            onPressed: () {
                              setState(() {
                                firstEnteredPIN = currentPIN;
                                state = "repeating";
                              });
                              widgetState!.clear();
                              widgetState!.changePinLength(currentPIN.length);
                            },
                            child: const Icon(
                              Icons.done,
                            ),
                          ),
                        )),
            ),
          ],
        ),
      )),
    );
  }
}
