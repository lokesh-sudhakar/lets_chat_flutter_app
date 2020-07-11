import 'package:shared_preferences/shared_preferences.dart';

class ChatPreferences {

  static const USER_LOGGED_IN_KEY = "is_user_logged_in";
  static const USER_NAME_KEY = "user_name_key";
  static const USER_EMAIL_KEY = "user_email_key";
  static const FIREBASE_TOKEN = "firebase_token";


  static Future<void> saveUserLoggedIn(bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(USER_LOGGED_IN_KEY, isUserLoggedIn);
  }

  static Future<void> saveUserName(String userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(USER_NAME_KEY, userName);
  }

  static Future<void> saveUserEmail(String userEmail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(USER_EMAIL_KEY, userEmail);
  }

  static Future<void> saveUserid() {

  }

  static Future<void> saveFirebaseToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(FIREBASE_TOKEN, token);
  }


  static Future<bool> getUserLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool value = preferences.getBool(USER_LOGGED_IN_KEY);
    if (value == null) {
      return false;
    } else {
      return value;
    }
  }

  static Future<String> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(USER_NAME_KEY);
  }

  static Future<String> getUserEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(USER_EMAIL_KEY);
  }

  static Future<String> getFirebaseToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(FIREBASE_TOKEN);
  }

  static void clearPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(USER_NAME_KEY, null);
    preferences.setBool(USER_LOGGED_IN_KEY, false);
    preferences.setString(USER_EMAIL_KEY, null);
  }


}