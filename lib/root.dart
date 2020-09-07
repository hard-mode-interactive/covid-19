import 'package:covidtracker/utilities/screenSize.dart';
import 'package:covidtracker/views/autenticacion/iniciar_sesion/iniciar_sesion.dart';
import 'package:covidtracker/views/pantalla_inicio/pantalla_inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth.dart';



class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}


enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  FirebaseUser _currentUser;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void loginCallback() {
    widget.auth.getUser().then((user) {
      setState(() {
        _currentUser = user;
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      widget.auth.logout();
      authStatus = AuthStatus.NOT_LOGGED_IN;

      _currentUser = null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.auth.getUser().then((user) {
      setState(() {
        if (user != null) {
          _currentUser = user;
        }
        authStatus =
        user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginPage(auth: widget.auth,login: loginCallback,);
        break;
      case AuthStatus.LOGGED_IN:
        if ( _currentUser != null ) {
          return HomePage(currentUser: _currentUser,auth: widget.auth,logOut: logoutCallback,prefs: _prefs,);
        } else
          return Center(
            child: CircularProgressIndicator(),
          );
        break;
      default:
        return Center(
          child: CircularProgressIndicator(),
        );
    }
  }
}
