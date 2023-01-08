import 'package:shared_preferences/shared_preferences.dart';

class SPHelper {
  SPHelper._();
  static SPHelper sp = SPHelper._();
  SharedPreferences? prefs;
  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> save(String name, String value) async {
    await prefs!.setString(name, value);
  }

  String? get(String key) {
    return prefs!.getString(key);
  }

  Future<bool> delete(String key) async {
    return await prefs!.remove(key);
  }
}
