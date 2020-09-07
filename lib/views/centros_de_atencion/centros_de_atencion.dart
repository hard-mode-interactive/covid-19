import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../utilities/screenSize.dart';

class CentrosDeAtencionPage extends StatefulWidget {
  CentrosDeAtencionPage({this.currentUser});
  final FirebaseUser currentUser;

  @override
  _CentrosDeAtencionPageState createState() => _CentrosDeAtencionPageState();
}

class _CentrosDeAtencionPageState extends State<CentrosDeAtencionPage> {
  var _firebaseRef;

  bool _loading = true;

  GoogleMapController mapController;

  LatLng _center = const LatLng(13.6929403, -89.2181911);
  Position currentLocation;
  Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getData() async {
    setState(() {
      _loading = true;
    });
    _markers.clear();



    _firebaseRef = FirebaseDatabase()
        .reference()
        .child('centros_de_atencion')
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> _centros = snapshot.value;
      if(_centros != null){
        _centros.forEach((key, info) {
          setState(() {

            final marker = Marker(

              markerId: MarkerId(key),
              position: LatLng(info['location']['lat'], info['location']['long']),
              infoWindow: InfoWindow(title: '${info['nombre']}', snippet: 'Tel: ${info['telefono']}'),
            );

            _markers[key] = marker;

          });
        });
      }


      setState(() {
        _loading = false;
      });


    });


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
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
          iconTheme: IconThemeData(color: Colors.white),

          title: Text('CENTROS DE ATENCION',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
          backgroundColor: Colors.orange[700],
          actions: <Widget>[
            IconButton(
              onPressed: _getData,
              icon: Icon(Icons.autorenew,color: Colors.white,),
            )
          ],
        ),

        body: !_loading
            ? GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 9.0,
                ),
                markers: _markers.values.toSet(),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
