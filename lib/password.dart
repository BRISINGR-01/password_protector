import 'package:flutter/material.dart';
import 'package:password_protector/pin.dart';
import 'package:password_protector/safe_exit.dart';
import 'package:password_protector/security_layers.dart';
import 'package:passwordfield/passwordfield.dart';

class UserPassword extends StatefulWidget {
  final int layerIndex;
  final bool enableSwitching;
  const UserPassword(
      {Key? key, required this.layerIndex, required this.enableSwitching})
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
                  if (password == "asd") {
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
