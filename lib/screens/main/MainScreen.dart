import 'dart:convert';

import 'package:fileextractor/constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fileextractor/main.dart';
import 'package:fileextractor/modal/FileInfo.dart';

class MainScreen extends StatefulWidget {
  String type;
  MainScreen({this.type});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/ic_backround.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              // FacebookBannerAd(
              //   placementId: SplashScreen.adsConfig["facebook"]["banner"],
              //   bannerSize: BannerSize.LARGE,
              //   listener: (result, value) {
              //     print("Banner Ad: $result -->  $value");
              //     switch (result) {
              //       case BannerAdResult.ERROR:
              //         break;
              //       case BannerAdResult.LOADED:
              //         break;
              //       case BannerAdResult.CLICKED:
              //         break;
              //       case BannerAdResult.LOGGING_IMPRESSION:
              //         break;
              //     }
              //   },
              // ),
              Expanded(
                child: ListFolder(
                  type: widget.type,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ListFolder extends StatefulWidget {
  ListFolder({this.type});
  String type;

  @override
  _ListFolderState createState() => _ListFolderState();
}

class _ListFolderState extends State<ListFolder> {
  @override
  void initState() {
    super.initState();
    getFolderandFile(curcentPath);
  }

  String curcentPath = "/storage/emulated/0";
  String rootPath = "/storage/emulated/0";
  String previousPath = "/storage/emulated/0";
  List<FileInfo> arrFileInfor = new List<FileInfo>();
  void getFolderandFile(String path) {
    curcentPath = path;
    previousPath = curcentPath.substring(0, curcentPath.lastIndexOf("/"));
    arrFileInfor = new List<FileInfo>();
    MyApp.platform.invokeMethod("loadPathInfo", {"path": path}).then((value) {
      for (int i = 0; i < jsonDecode(value).length; i++) {
        // print(jsonDecode(value)[i].runtimeType);
        arrFileInfor.add(FileInfo.fromJson(jsonDecode(value)[i]));
      }
      setState(() {
        arrFileInfor.sort((a, b) {
          return a.fileName.compareTo(b.fileName);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/ic_backround.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: HEADER_COLOR,
          child: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: Container(
              color: HEADER_COLOR,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    height: 40,
                    color: HEADER_COLOR,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      curcentPath,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  (previousPath + "/0").compareTo(curcentPath) == 0
                      ? Container(
                          height: 0,
                        )
                      : Container(
                          height: 40,
                          color: HEADER_COLOR,
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              getFolderandFile(previousPath);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                Text(
                                  "   " + previousPath,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: new ListView.builder(
                          itemCount: arrFileInfor.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Column(
                              children: <Widget>[
                                Container(
                                  height: 70,
                                  margin: EdgeInsets.all(5),
                                  child: FlatButton(
                                    splashColor: Colors.black12,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      switch (arrFileInfor[index].fileType) {
                                        case "folderEmpty":
                                        case "folderFull":
                                          getFolderandFile(arrFileInfor[index].filePath);
                                          break;
                                        case "fileArchive":
                                          Navigator.pop(context, {"path": arrFileInfor[index].filePath, "type": "file"});
                                          break;
                                        case "fileUnknown":
                                          break;
                                      }

                                      // print();
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: Image.asset(
                                            arrFileInfor[index].fileType.compareTo("folderFull") == 0
                                                ? "lib/assets/images/ic_folder.png"
                                                : arrFileInfor[index].fileType.compareTo("fileArchive") == 0
                                                    ? "lib/assets/images/ic_file_archive.png"
                                                    : arrFileInfor[index].fileType.compareTo("fileUnknown") == 0
                                                        ? "lib/assets/images/ic_unknown.png"
                                                        : "lib/assets/images/ic_folder.png",
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                arrFileInfor[index].fileName,
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16, color: ROW1_COLOR, fontWeight: FontWeight.normal),
                                              ),
                                              Text(
                                                arrFileInfor[index].subCount.toString(),
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16, color: ROW2_COLOR, fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: ROW_COLOR,
                                  margin: EdgeInsets.only(left: 75, right: 20),
                                )
                              ],
                            );
                          }),
                    ),
                  ),
                  widget.type.compareTo("folder") == 0
                      ? Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            child: Text(
                              "Select folder",
                              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pop(context, {"path": curcentPath, "type": "folder"});
                            },
                          ),
                        )
                      : Container(
                          height: 0,
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
