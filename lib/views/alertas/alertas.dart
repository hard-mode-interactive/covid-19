import 'package:covidtracker/views/alerta/alerta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utilities/screenSize.dart';


class AlertasPage extends StatefulWidget {
  AlertasPage({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _AlertasPageState createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  bool _loading = true;



  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('usuarios').child(widget.currentUser.uid).child('alertas');

    setState(() {
      _loading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.orange[700],
          title: Text('ALERTAS DE CONTAGIO',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        ),
        body: !_loading ?  StreamBuilder(
          stream: _firebaseRef.onValue,
          builder: (context, snap) {

            if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

              Map data = snap.data.snapshot.value;
              List item = [];

              data.forEach((key, value) {
                Map<String,dynamic> alerta = {
                  "key": key,
                  "title": value['title'],
                  "body": value['body'],
                  "direction": value['direction'],
                  "date": value['date'],
                  "lat1": value['lat1'],
                  "lat2": value['lat2'],
                  "long1": value['long1'],
                  "long2": value['long2']

                };
                item.add(alerta);
              });

              return ListView.builder(
                itemCount: item.length,

                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 10.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20.0),
                      dense: true,
                      leading: Icon(Icons.person_pin_circle,color: Colors.red,),
                      title: Text('${item[index]['direction']}'),
                      subtitle: Text('${item[index]['date']}'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AlertaPage(notification: item[index],currentUser: widget.currentUser,)
                        ));
                      },
                    ),
                  );
                },
              );
            }
            else
              return Center(
                child: Text('No hay informacion.',style: TextStyle(color: Colors.black26),),
              );
          },
        ) : Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
