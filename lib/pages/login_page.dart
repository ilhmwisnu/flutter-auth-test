import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/pages/home_page.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
// import 'dashboard_screen.dart';

const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUserSignUp(LoginData data) async {
    // print('Name: ${data.name}, Password: ${data.password}');
    try {
      var prov = Provider.of<Auth>(context, listen: false);
      await prov.signUp(data.name, data.password);
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  Future<String> _authUserSignIn(LoginData data) async {
    // print('Name: ${data.name}, Password: ${data.password}');
    try {
      var prov = Provider.of<Auth>(context, listen: false);
      await prov.signIn(data.name, data.password);
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  Future<String> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'Username not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'Username not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'TEST',
      // logo: 'assets/images/ecorp-lightblue.png',
      onLogin: _authUserSignIn,
      onSignup: _authUserSignUp,
      onSubmitAnimationCompleted: () {
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => HomePage(),
        // ));
        // Navigator.pushReplacementNamed(context, HomePage.route);
        Provider.of<Auth>(context, listen: false).run();
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
