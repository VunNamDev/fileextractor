import 'dart:math';

import 'package:edge_alert/edge_alert.dart';
import 'package:fileextractor/utils/SharedPreferencesUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fileextractor/constants/Constants.dart';
import 'package:fileextractor/main.dart';
import 'package:fileextractor/screens/main/MainScreen.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class SelectScreen extends StatefulWidget {
  String zippath = "";
  SelectScreen();
  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  TextEditingController fileControllner;
  TextEditingController folderControllner = new TextEditingController();
  TextEditingController passwordControllner = new TextEditingController();
  Future<void> getAndShowAd(context) async {
    mainExtract();
  }

  void showAlert(String content, Color color) {
    EdgeAlert.show(context, title: 'Messages', description: content, gravity: EdgeAlert.TOP, backgroundColor: color, duration: 3);
  }

  @override
  void initState() {
    folderControllner.text = "/storage/emulated/0/ExtractFolder";
    fileControllner = new TextEditingController(text: widget.zippath);
    super.initState();
  }

  void nextScreen(String type) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MainScreen(
                type: type,
              )),
    );
    if (res != null) {
      switch (res["type"]) {
        case "file":
          fileControllner.text = res["path"];
          folderControllner.text = "/storage/emulated/0/ExtractFolder";
          break;
        case "folder":
          folderControllner.text = res["path"];
          break;
      }
    }
  }

  void rate() {
    MyApp.platform.invokeMethod("rateManual");
  }

  bool firstRun = false;
  void mainExtract() async {
    // showAlert("Failse to extract file\nCheck your pass word", Colors.red);
    int rateCount = SharedPreferencesUtil.getIntData("rate");
    if (rateCount != 0) {
      firstRun = false;
      if (fileControllner.text.isNotEmpty && folderControllner.text.isNotEmpty) {
        String folderName =
            fileControllner.text.substring(fileControllner.text.lastIndexOf("/"), fileControllner.text.lastIndexOf(".")) + "-ext";
        print(passwordControllner.text);
        await MyApp.platform.invokeMethod("extract", {
          "path": fileControllner.text,
          "outPath": folderControllner.text + folderName,
          "title": "Extracting...",
          "content": "Extracting...",
          "password": passwordControllner.text
        }).then((value) {
          print(value);
          MyApp.platform.invokeMethod("dismissProgressDialog");
          myCallback(value);
        });
      }
    } else {
      if (fileControllner.text.isNotEmpty && folderControllner.text.isNotEmpty) {
        String folderName =
            fileControllner.text.substring(fileControllner.text.lastIndexOf("/"), fileControllner.text.lastIndexOf(".")) + "-ext";
        print(passwordControllner.text);
        await MyApp.platform.invokeMethod("extract", {
          "path": fileControllner.text,
          "outPath": folderControllner.text + folderName,
          "title": "Extracting...",
          "content": "Extracting...",
          "password": passwordControllner.text
        }).then((value) {
          MyApp.platform.invokeMethod("dismissProgressDialog");
          myCallback(value);
          rateCount = rateCount + 1;
          firstRun = true;
          SharedPreferencesUtil.setIntData("rate", rateCount);
        });
      }
    }
  }

  void _showDialog(context, imageAssetsUrl, des) {
    showDialog(
      context: context,
      builder: (_) => AssetGiffyDialog(
        image: Image.asset(imageAssetsUrl),
        title: Text(
          'Messages',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
        ),
        description: Text(
          des,
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
        onlyOkButton: true,
        entryAnimation: EntryAnimation.BOTTOM,
        onOkButtonPressed: () async {
          Navigator.pop(context);
          if (firstRun) {
            print(firstRun);
            MyApp.platform.invokeMethod("rate");
          }
        },
      ),
    );
  }

  void myCallback(value) {
    if (value.compareTo("EXIT_OK") == 0) {
      _showDialog(context, "lib/assets/gifs/ok.gif", "Extract file complete");
    }

    if (value.compareTo("EXIT_FATAL") == 0) {
      _showDialog(context, "lib/assets/gifs/error.gif", "False to extract file\nCheck your pass word");
      //false
    }
    if (value.compareTo("EXIT_MEMORY_ERROR") == 0) {
      _showDialog(context, "lib/assets/gifs/error.gif", "Memory not enough");
      //memory
    }
    passwordControllner.text = "";
    fileControllner.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/images/ic_backround.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: HEADER_COLOR,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              "File extractor",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          height: 50,
                          width: 50,
                        )
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width - 160,
                                    height: 40,
                                    child: Center(
                                      child: TextField(
                                        controller: fileControllner,
                                        textAlign: TextAlign.left,
                                        enabled: false,
                                        style: TextStyle(fontSize: 16),
                                        decoration: new InputDecoration(
                                          hintText: 'Select file',
                                          // border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    height: 50,
                                    child: FlatButton(
                                      padding: EdgeInsets.only(left: 5, right: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset(
                                            "lib/assets/images/ic_folder.png",
                                            width: 25,
                                          ),
                                          // Icon(
                                          //   Icons.folder,
                                          //   size: 30,
                                          //   color: Colors.yellow,
                                          // ),
                                          Text("  Browser"),
                                        ],
                                      ),
                                      onPressed: () {
                                        nextScreen("file");
                                      },
                                      // padding: EdgeInsets.all(0),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    width: MediaQuery.of(context).size.width - 160,
                                    height: 40,
                                    child: Center(
                                      child: TextField(
                                        controller: passwordControllner,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 16),
                                        decoration: new InputDecoration(
                                          hintText: "Password / Blank if file not require",
                                          // border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    height: 50,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width - 160,
                                    height: 40,
                                    child: Center(
                                      child: TextField(
                                        controller: folderControllner,
                                        textAlign: TextAlign.left,
                                        enabled: false,
                                        style: TextStyle(fontSize: 16),
                                        decoration: new InputDecoration(
                                          hintText: 'Select extract folder',
                                          // border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    height: 50,
                                    child: FlatButton(
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset(
                                            "lib/assets/images/ic_folder.png",
                                            width: 25,
                                          ),
                                          Text("  Browser"),
                                        ],
                                      ),
                                      onPressed: () {
                                        nextScreen("folder");
                                      },
                                      padding: EdgeInsets.only(left: 5, right: 5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: new BoxDecoration(
                                color: ADD_COLOR,
                                borderRadius: new BorderRadius.all(
                                  Radius.circular(25),
                                ),
                              ),
                              height: 50,
                              width: 200,
                              child: FlatButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                child: Text(
                                  "Extract file",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  getAndShowAd(context);
                                },
                                padding: EdgeInsets.only(left: 5, right: 5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
