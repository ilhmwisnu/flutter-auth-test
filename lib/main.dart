import 'package:flutter/material.dart';
import 'package:flutter_auth/models/product.dart';
import 'package:flutter_auth/pages/login_page.dart';
import 'package:flutter_auth/providers/auth.dart';
import 'package:provider/provider.dart';

import './providers/products.dart';

import './pages/home_page.dart';
import './pages/add_product_page.dart';
import './pages/edit_product_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (ctx) => Products(),
              update: (context, auth, prod) =>
                  prod..updateData(auth.token, auth.userId))
          // ChangeNotifierProvider(create: (ctx) => Products()),
        ],
        builder: (context, child) {
          var prov = Provider.of<Auth>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: (prov.isAuth)
                ? HomePage()
                : FutureBuilder(
                    future: prov.autoLogin(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(body: Center(
                          child: CircularProgressIndicator(),
                        ),);
                      }
                      return LoginScreen();
                    },
                  ),
            routes: {
              HomePage.route: (ctx) => HomePage(),
              AddProductPage.route: (ctx) => AddProductPage(),
              EditProductPage.route: (ctx) => EditProductPage(),
            },
          );
        });
  }
}
