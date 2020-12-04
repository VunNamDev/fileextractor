import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static SharedPreferences prefs;
  static Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    print('Pressed $counter times.');
    await prefs.setInt('counter', counter);
  }

  static dynamic removeDta(String key) async {
    return await prefs.remove(key);
  }

  static String getData(String key) {
    if (prefs.get(key) == null) {
      return "[]";
    }
    return prefs.get(key);
  }

  static dynamic getListData(String key) {
    if (prefs.get(key) == null) return [];
    return prefs.get(key);
  }

  static dynamic setData(String key, String value) {
    return prefs.setString(key, value);
  }

  static dynamic setListData(String key, dynamic value) {
    return prefs.setString(key, value);
  }

  static int getIntData(String key) {
    if (prefs.getInt(key) == null) {
      return 0;
    }
    return prefs.getInt(key);
  }

  static dynamic setIntData(String key, int value) {
    return prefs.setInt(key, value);
  }
}
