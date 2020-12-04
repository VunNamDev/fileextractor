import 'package:fileextractor/constants/Constants.dart';
import 'package:fileextractor/screens/select/SelectScreen.dart';
import 'package:fileextractor/utils/SharedPreferencesUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesUtil.initSharedPreferences();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const platform = const MethodChannel('samples.flutter.dev');
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SelectScreen(),
    );
  }
}
