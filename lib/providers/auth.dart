import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  Timer logOutTimer;
  DateTime _expireDate;
  String _idToken, userId;
  DateTime tempExpireDate;
  String tempIdToken, tempUserId;

  String get token {
    if (_idToken != null && _expireDate.isAfter(DateTime.now())) {
      return _idToken;
    } else {
      return null;
    }
  }

  Future<void> run() async {
    _expireDate = tempExpireDate;
    userId = tempUserId;
    _idToken = tempIdToken;

    final data = {
      "token": _idToken,
      "userId": userId,
      "expireDate": _expireDate.toIso8601String()
    };

    final authData = json.encode(data);

    final pref = await SharedPreferences.getInstance();
    pref.setString("authData", authData);

    notifyListeners();
  }

  bool get isAuth => token != null;

  Future<void> signUp(String email, String password) async {
    try {
      Uri url = Uri.tryParse(
          "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCgjpxPpoPoJ6RRx1uMnDZLRCW2pFFfljM");
      var response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));
      print(response.body);
      var responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        print(responseData['error']['message']);
        throw responseData['error']['message'];
      } else {
        tempIdToken = responseData["idToken"];
        tempUserId = responseData["localId"];
        tempExpireDate = DateTime.now()
            .add(Duration(seconds: int.tryParse(responseData["expiresIn"])));
        // notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      Uri url = Uri.tryParse(
          "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCgjpxPpoPoJ6RRx1uMnDZLRCW2pFFfljM");
      var response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));
      // print(response.body);
      var responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        // print(responseData['error']['message']);
        throw responseData['error']['message'];
      } else {
        tempIdToken = responseData["idToken"];
        tempUserId = responseData["localId"];
        tempExpireDate = DateTime.now()
            .add(Duration(seconds: int.tryParse(responseData["expiresIn"])));
        // notifyListeners();
      }
    } catch (e) {
      // print(e.toString());
      rethrow;
    }
  }

  void logOut() async {
    _expireDate = null;
    _idToken = null;
    userId = null;

    var pref = await SharedPreferences.getInstance();
    pref.clear();

    notifyListeners();
  }

  void autoLogOut() {
    if (logOutTimer != null) {
      logOutTimer.cancel();
      logOutTimer = null;
    }

    var detik = _expireDate.difference(DateTime.now()).inSeconds;
    print(detik);
    logOutTimer = Timer(Duration(seconds:detik ), logOut);
  }

  Future<void> autoLogin() async {
    var pref = await SharedPreferences.getInstance();

    if (!pref.containsKey("authData")) {
      return false;
    }

    var data = pref.getString("authData");
    var authData = json.decode(data);

    _expireDate = DateTime.parse(authData["expireDate"]);
    userId = authData["userId"];
    _idToken = authData["token"];

    notifyListeners();
  }
}
