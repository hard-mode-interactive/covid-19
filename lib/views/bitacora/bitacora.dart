import 'package:covidtracker/views/ubicacion_guardada/registro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utilities/screenSize.dart';


class Historial extends StatefulWidget {
  Historial({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  bool _loading = true;



  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('usuarios').child(widget.currentUser.uid).child('bitacora_lugares').orderByChild('timeStamp');

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
        title: Text('BITACORA DE LUGARES',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
      ),
      body: !_loading ?  StreamBuilder(
        stream: _firebaseRef.onValue,
        builder: (context, snap) {

          if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

            Map data = snap.data.snapshot.value;
            List item = [];

            bool byTimeStamp = true;

            data.forEach((index,data){
              if(data['timeStamp'] == null){
                byTimeStamp = false;
              }
            });


            data.forEach((key, value) {
              Map<String,dynamic> bitacora = {
                "key": key,
                "direccion": value['direccion'],
                "fecha": value['fecha'],
                "foto": value['foto'],
                "location": value['location'],
                "nombre": value['nombre'],
                "notas": value['notas'],
                "timeStamp": value['timeStamp']

              };
              item.add(bitacora);
            });



            if(!byTimeStamp){
              item.sort((a, b) {
                return b["fecha"].compareTo(a["fecha"]);
              });

            }
            else
            {
              item.sort((a, b) {
                return b["timeStamp"].compareTo(a["timeStamp"]);
              });

            }


            return ListView.builder(
              itemCount: item.length,
              itemBuilder: (context, index) {
                print('${item[index]['key']}: ${item[index]['fecha']}');
                return Card(
                  margin: EdgeInsets.all(10.0),
                  elevation: 10.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20.0),
                    dense: true,
                    leading: Icon(Icons.location_on,color: Colors.deepOrangeAccent,),
                    trailing: Icon(Icons.more_vert),
                    title: item[index]['nombre'].length > 0 ? Text(item[index]['nombre']) : Text('${item[index]['direccion']}'),

                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10.0,
                        ),
                        Text('${item[index]['fecha']}'),
//                        Text('${item[index]['location']['lat']}, ${item[index]['location']['long']}')
                      ],
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => RegistroPage(currentUser: widget.currentUser,registro: item[index],)
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
