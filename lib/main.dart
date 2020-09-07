


import 'package:covidtracker/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:load/load.dart';
import 'services/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp());
  });

}

class MyApp extends StatelessWidget {
  final BaseAuth auth = new Auth();


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'COVID-19 Tracker',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: RootPage(auth: auth,),
      builder: (context, widget) {
        return LoadingProvider(
          child: widget,
        );
      },
    );
  }
}

