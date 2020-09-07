
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../utilities/screenSize.dart';


class ZonasPage extends StatefulWidget {
  ZonasPage({this.currentUser});
  final FirebaseUser currentUser;

  @override
  _ZonasPageState createState() => _ZonasPageState();
}

class _ZonasPageState extends State<ZonasPage> {
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
        .child('ubicaciones_de_riesgo')
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> _usuarios = snapshot.value;
      if(_usuarios != null){
        _usuarios.forEach((key, ubicaciones) {
          ubicaciones.forEach((key,data){
                      setState(() {

            final marker = Marker(

              markerId: MarkerId(key),
              position: LatLng(data['location']['lat'], data['location']['long']),
              infoWindow: InfoWindow(title: '${data['location']['direction']}'),
            );

            _markers[key] = marker;

          });
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

        title: Text('ZONAS DE RIESGO',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        backgroundColor: Colors.orange[700],

      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[700],
        onPressed: _getData,
        tooltip: 'Get Location',
        child: Icon(Icons.autorenew,color: Colors.white,),
      ),
      body: !_loading
          ? GoogleMap(

        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 9.0,
        ),
        markers: _markers.values.toSet(),
      )
          : Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}
