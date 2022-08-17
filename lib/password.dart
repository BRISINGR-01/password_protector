import 'package:flutter/material.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/pin.dart';
import 'package:password_protector/safe_exit.dart';
import 'package:password_protector/security_layers.dart';
import 'package:password_protector/settings.dart';
import 'package:passwordfield/passwordfield.dart';

class UserPassword extends StatefulWidget {
  final int layerIndex;
  final bool enableSwitching;
  final Map<String, String> passwords;

  const UserPassword(
      {Key? key,
      required this.layerIndex,
      required this.enableSwitching,
      required this.passwords})
      : super(key: key);

  @override
  State<UserPassword> createState() => _UserPasswordState();
}

class _UserPasswordState extends State<UserPassword> {
  final TextEditingController controller = TextEditingController();
  bool isWrong = false;

  @override
  Widget build(BuildContext context) {
    return SafeExit(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Password'),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: !widget.enableSwitching
                ? null
                : FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.swap_horiz_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPIN(
                              layerIndex: widget.layerIndex,
                              enableSwitching: widget.enableSwitching,
                              passwords: widget.passwords,
                            ),
                          ));
                    }),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PasswordField(
                passwordConstraint: r'.*',
                hintText: isWrong ? "Wrong password" : "Password",
                autoFocus: true,
                controller: controller,
                color: Theme.of(context).colorScheme.primary,
                onSubmit: ((password) {
                  if (password == widget.passwords["password"]) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SecurityLayers(layerIndex: widget.layerIndex + 1),
                        ));
                  } else {
                    setState(() {
                      isWrong = true;
                    });

                    Future.delayed(const Duration(milliseconds: 300))
                        .then((value) => setState(() {
                              isWrong = false;
                            }));
                  }

                  controller.clear();
                }),
                inputDecoration: PasswordDecoration(),
                backgroundColor:
                    isWrong ? Theme.of(context).colorScheme.error : null,
                border: PasswordBorder(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isWrong
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: isWrong
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 2, color: Theme.of(context).colorScheme.error),
                  ),
                ),
                errorMessage: isWrong ? 'Wrong password!' : "",
              ),
            )),
      ),
    );
  }
}

class SetPassword extends StatefulWidget {
  const SetPassword({Key? key}) : super(key: key);

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final DataHelper dataHelper = DataHelper();

  String state = "first password";
  String currentPassword = "";
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeExit(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                "${state == "first password" ? "Set" : state == "repeating" ? "Repeat" : "Wrong"} password"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PasswordField(
                passwordConstraint: r'.*',
                hintText: state == "first password"
                    ? "Type in your new password"
                    : state == "repeating"
                        ? "Repeat your password"
                        : "Wrong! Try Again",
                autoFocus: true,
                color: Theme.of(context).colorScheme.primary,
                onSubmit: ((password) {
                  if (password.isEmpty) return;

                  controller.clear();
                  if (state == "first password") {
                    setState(() {
                      state = "repeating";
                      currentPassword = password;
                    });
                  } else if (state == "repeating") {
                    if (currentPassword == password) {
                      dataHelper.setSetting("password", password);
                      dataHelper.setSetting("usePassword", "true");
                      dataHelper.setSetting("defaultIsPIN", "false");

                      Navigator.pop(context); // remove the `Set password` route
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
                        currentPassword = "";
                      });
                      Future.delayed(const Duration(milliseconds: 600))
                          .then((_) => setState(() {
                                state = "first password";
                              }));
                    }
                  }
                }),
                controller: controller,
                inputDecoration: PasswordDecoration(),
                border: PasswordBorder(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 2, color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
