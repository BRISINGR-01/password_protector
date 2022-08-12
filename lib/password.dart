import 'package:flutter/material.dart';
import 'package:password_protector/app.dart';
import 'package:password_protector/pin.dart';
import 'package:password_protector/safe_exit.dart';
import 'package:passwordfield/passwordfield.dart';

class UserPassword extends StatelessWidget {
  const UserPassword({Key? key}) : super(key: key);

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
            floatingActionButton: FloatingActionButton(
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
                        builder: (context) => const UserPIN(),
                      ));
                }),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PasswordField(
                passwordConstraint: r'.*',
                autoFocus: true,
                color: Theme.of(context).colorScheme.primary,
                onSubmit: ((password) {
                  if (password == "asd") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => App(),
                        ));
                  }
                }),
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
                // errorMessage: 'must contain special character either . * @ # \$',
              ),
            )),
      ),
    );
  }
}
