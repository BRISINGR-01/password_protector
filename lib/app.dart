import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:password_protector/data.dart';
import 'package:password_protector/safe_exit.dart';
import 'package:password_protector/security_layers.dart';
import 'package:password_protector/settings.dart';

import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  DataHelper dataHelper = DataHelper();
  bool isLoaded = false;
  bool choosingToEdit = false;
  List<Map<String, String>> elements = [];
  int showTextIndex = -1;
  int editingIndex = -1;
  Map<String, String> currentEdited = {"name": "", "value": ""};

  add() {
    elements.add({"name": "", "value": ""});
    setState(() {
      choosingToEdit = false;
      editingIndex = elements.length - 1;
    });
    dataHelper.setSetting("userData", json.encode(elements));
  }

  startEditing(index) {
    setState(() {
      choosingToEdit = false;
      editingIndex = index;
      currentEdited = {...elements[index]};
    });
  }

  delete(index) {
    elements.removeAt(index);
    setState(() {
      elements;
      if (elements.isEmpty) choosingToEdit = false;
    });
    dataHelper.setUserData(elements);
  }

  saveData() {
    elements[editingIndex] = {...currentEdited};
    setState(() {
      editingIndex = -1;
    });
    dataHelper.setUserData(elements);
  }

  @override
  void initState() {
    super.initState();
    dataHelper.getUserData().then((data) => setState((() {
          isLoaded = true;
          elements = data;
        })));
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator())),
      );
    }

    return SafeExit(
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: const Text("Passwords"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                tooltip: "Edit",
                onPressed: () => setState(() {
                      choosingToEdit = elements.isNotEmpty && !choosingToEdit;
                      editingIndex = -1;
                    }),
                icon: Icon(
                  Icons.edit,
                  color: choosingToEdit
                      ? Theme.of(context).colorScheme.tertiary
                      : null,
                )),
            IconButton(
                tooltip: "Go to Settings",
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Settings(),
                    )),
                icon: const Icon(Icons.settings)),
            IconButton(
                tooltip: "Lock",
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SecurityLayers(layerIndex: 0)),
                    (route) => false),
                icon: const Icon(Icons.lock_outline))
          ],
        ),
        floatingActionButton: choosingToEdit || editingIndex != -1
            ? null
            : FloatingActionButton(
                onPressed: add,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                child: const Icon(Icons.add),
              ),
        body: ListView.builder(
            itemCount: elements.length,
            itemBuilder: ((context, index) {
              if (editingIndex == index) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == elements.length - 1 ? 100 : 0,
                      top: index == 0 ? 20 : 0),
                  child: ListTile(
                    title: ListTile(
                      leading: const Text("name:"),
                      title: TextFormField(
                        initialValue: elements[index]["name"],
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onChanged: (val) => setState(() {
                          currentEdited["name"] = val;
                        }),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.lightGreenAccent.shade400,
                        ),
                        onPressed: saveData,
                      ),
                    ),
                    subtitle: ListTile(
                      leading: const Text("value:"),
                      title: TextFormField(
                        initialValue: elements[index]["value"],
                        textInputAction: TextInputAction.done,
                        onChanged: (val) => setState(() {
                          currentEdited["value"] = val.trim();
                        }),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => setState(() {
                          editingIndex = -1;
                          currentEdited = {};
                        }),
                      ),
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: choosingToEdit ? () => startEditing(index) : null,
                  onLongPressDown: (_) => setState(() {
                    showTextIndex = index;
                  }),
                  onLongPressEnd: (_) => setState(() {
                    showTextIndex = -1;
                  }),
                  onLongPressCancel: () => setState(() {
                    showTextIndex = -1;
                  }),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: index == elements.length - 1 ? 100 : 0,
                        top: index == 0 ? 20 : 0),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text("▸ ${elements[index]["name"] ?? ""}"),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: TextFormField(
                          enabled: false,
                          initialValue: elements[index]["value"],
                          obscureText: showTextIndex != index,
                          readOnly: true,
                        ),
                      ),
                      trailing: choosingToEdit
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => startEditing(index),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => delete(index),
                                ),
                              ],
                            )
                          : IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                if (elements[index]["value"]!.isNotEmpty) {
                                  ClipboardData data = ClipboardData(
                                      text: elements[index]["value"]);
                                  Clipboard.setData(data).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            duration:
                                                Duration(milliseconds: 600),
                                            content: Text(
                                                'Copied to your clipboard !')));
                                  });
                                }
                              },
                            ),
                    ),
                  ),
                );
              }
            })),
      )),
    );
  }
}
