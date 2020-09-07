import 'dart:async';
import 'dart:io';

import 'package:covidtracker/views/alertas/alertas.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:covidtracker/utilities/screenSize.dart';
import 'package:covidtracker/views/alerta/alerta.dart';
import 'package:covidtracker/views/bitacora/bitacora.dart';
import 'package:covidtracker/views/centros_de_atencion/centros_de_atencion.dart';
import 'package:covidtracker/views/consejos_utiles/consejos.dart';
import 'package:covidtracker/views/guardar_ubicacion/guardar_ubicacion.dart';
import 'package:covidtracker/views/notificaciones/notificaciones.dart';
import 'package:covidtracker/views/zonas_de_riesgo/zonas_de_riesgo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../services/guardar_ubicacion.dart';

import 'package:firebase_messaging/firebase_messaging.dart';


class HomePage extends StatefulWidget {
  HomePage({this.currentUser,this.auth,this.logOut,this.prefs});
  final FirebaseUser currentUser;
  final auth;
  final VoidCallback logOut;
  final prefs;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  var _token;
  var uuid = Uuid();
  bool _loading = true;
  bool _serviceRunning = false;
  GoogleMapController mapController;

  LatLng _center;
  Position currentLocation;
  final Map<String, Marker> _markers = {};

  SharedPreferences prefs;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getLocation() async {
    setState(() {
      _loading = true;
    });

    currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Tu ubicacion'),
      );
      _markers["Current Location"] = marker;
      _loading = false;
    });


  }


  void _getServiceState() async {

    setState(() {
      _loading = true;
    });

    if(Platform.isAndroid){
      var methodChannel = MethodChannel("com.murgasmedia.messages");
      bool state = await methodChannel.invokeMethod("serviceState");
      print("Service State: $state");
      setState(() {
        _serviceRunning = state;
      });
      if(_serviceRunning){
        startServiceInPlatform();
      }
    }

  }



  void _initNotifications(){
    firebaseMessaging.getToken().then((token){
      setState(() {
        _token = token;
      });
    });
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called: $message');
       /* if(message['data'] != null){
          if(message['data']['tipo'] != null && message['data']['tipo'] == "alerta"){
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AlertasPage(currentUser: widget.currentUser,)
            ));
          }
        }*/


      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called: $message');
        /*if(message['data'] != null){
          if(message['data']['tipo'] != null && message['data']['tipo'] == "alerta"){
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AlertasPage(currentUser: widget.currentUser,)
            ));
          }
        }*/
      },
      onLaunch: (Map<String, dynamic> message) {
        /*if(message['data'] != null){
          if(message['data']['tipo'] != null && message['data']['tipo'] == "alerta"){
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AlertasPage(currentUser: widget.currentUser,)
            ));
          }
        }*/
      },
    );


  }



  void startServiceInPlatform() async {
    if(Platform.isAndroid){
      var methodChannel = MethodChannel("com.murgasmedia.messages");
      String data = await methodChannel.invokeMethod("startService",{"userUid":widget.currentUser.uid});
      debugPrint(data);
    }
  }

  void stopServiceInPlatform() async {
    if(Platform.isAndroid){
      var methodChannel = MethodChannel("com.murgasmedia.messages");
      String data = await methodChannel.invokeMethod("stopService");
      debugPrint(data);
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getServiceState();
    _initNotifications();
    _getLocation();



  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: Text('UBICACION ACTUAL',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        backgroundColor: Colors.orange[700],
//        actions: <Widget>[
//
//          IconButton(
//            icon: Icon(Icons.save,color: Colors.white,),
//            onPressed: () async {
//
//              if(currentLocation != null){
//                Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => SavePage(
//                          currentPosition: currentLocation,currentUser: widget.currentUser,
//                        )));
//              }
//              else
//                {
//                  _getLocation();
//                }
//
//            },
//          ),
//
//        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[700],
        onPressed: ()  async {
          if(_serviceRunning){

            setState(() {
              _serviceRunning = false;
            });

            stopServiceInPlatform();


          }
          else
            {
              setState(() {
                _serviceRunning = true;
              });
              startServiceInPlatform();

            }
        },
        tooltip: 'Iniciar Tracking',
        child: Icon( _serviceRunning ? Icons.stop : Icons.play_arrow,color: Colors.white,),
      ),
      body: !_loading
          ? GoogleMap(
              onMapCreated: _onMapCreated,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.0,
              ),
              //markers: _markers.values.toSet(),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child:UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: ExactAssetImage('assets/drawer.png')
                      )
                  ),
                  accountEmail: Text(widget.currentUser.email,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[

                  ListTile(
                    leading: Icon(Icons.error),
                    title: Text('Alertas'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AlertasPage(currentUser: widget.currentUser,)
                      ));
                    },
                  ),

                  ListTile(
                    leading:  Icon(Icons.notification_important),
                    title: Text('Notificaciones'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => NotificacionesPage(currentUser: widget.currentUser,)
                      ));
                    },
                  ),

                  ListTile(
                    leading:  Icon(Icons.location_on),
                    title: Text('Mis Lugares'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Historial(currentUser: widget.currentUser,)
                      ));
                    },
                  ),
                  ListTile(
                    leading:  Icon(Icons.domain),
                    title: Text('Centros de Atencion'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CentrosDeAtencionPage(currentUser: widget.currentUser,)
                      ));
                    },
                  ),
                  ListTile(
                    leading:  Icon(Icons.warning),
                    title: Text('Zonas de Riesgo'),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(
                          builder: (context) => ZonasPage(currentUser: widget.currentUser,)
                      ));
                    },
                  ),
                  ListTile(
                    leading:  Icon(Icons.nature_people),
                    title: Text('Consejos Utiles'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ConsejosPage(currentUser: widget.currentUser,)
                      ));
                    },
                  ),
                  ListTile(
                    leading:  Icon(Icons.share),
                    title: Text('Compartir ID'),
                    onTap: () {
                      return showDialog(
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                            ),
                            title: Center(
                              child: Text("ID"),
                            ),
                            content:Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 60 * SizeConfig.blockSizeHorizontal,
                                  height: 35 * SizeConfig.blockSizeVertical ,
                                  child: QrImage(
                                    data: "${widget.currentUser.uid},${widget.currentUser.email},$_token",
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              FlatButton(

                                child: Text('cerrar'),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                              )

                            ],
                          );
                        },
                        context: context,
                      );

                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Salir'),
                    onTap: () async {
                      stopServiceInPlatform();
                      Navigator.pop(context);
                      widget.logOut();
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.all(75.0),
                    child: InkWell(
                        onTap: (){
                          return showDialog(
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                                ),
                                title: Text('Proximamente'),
                                content:Text('La aplicacion aun esta en fase de desarrollo'),
                                actions: <Widget>[
                                  FlatButton(

                                    child: Text('cerrar'),
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                  )

                                ],
                              );
                            },
                            context: context,
                          );
                        },
                        child: Text('Politica de privacidad',style: TextStyle(fontWeight: FontWeight.bold),)),
                  ),

                ],
              ),
            )
          ],
        )
      ),
    );
  }
}
