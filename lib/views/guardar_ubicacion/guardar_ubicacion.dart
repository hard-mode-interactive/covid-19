import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../utilities/screenSize.dart';

import '../../services/guardar_ubicacion.dart';


class SavePage extends StatefulWidget {
  SavePage({this.currentPosition,this.currentUser});
  final FirebaseUser currentUser;
  final Position currentPosition;
  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
   BaseGuardarUbicacion _guardarUbicacion = new GuardarUbicacion();

  File _image;

  String _notas = '';
  String _nombre = '';

  bool _loading = false;

  Future getImage() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var image = await ImagePicker.pickImage(source: ImageSource.camera,
        maxHeight: 1280.0,
        maxWidth: 1280.0);

    setState(() {
      _image = image;
    });
  }





    @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.orange[700],
          iconTheme: IconThemeData(color: Colors.white),
          title: Text('GUARDAR UBICACION',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),)
      ),
       floatingActionButton: !_loading ? FloatingActionButton(
        onPressed:  () async {

          if(!_loading)
            {
              setState(() {
                _loading = true;
              });
              var ubicacionGuardada = await _guardarUbicacion.guardar(widget.currentUser, widget.currentPosition, _nombre, _notas, _image);
              setState(() {
                _loading = true;
              });
              Navigator.pop(context);
            }

        },
        child: Icon(Icons.cloud_upload,color: Colors.white,),
      ) : Container(),
      body: !_loading ? SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child:   Column(
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            TextField(
              onChanged: (val) => _nombre = val,
              decoration: InputDecoration(
                  icon: Icon(Icons.subject),
                  labelText:'Nombre'
              ),
            ),


            SizedBox(
              height: 50.0,
            ),
            InkWell(
              onTap:getImage,
              child: Container(
                width: 400.0,
                height: 200.0,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black12
                    ),
                    borderRadius: BorderRadius.circular(5.0)
                ),
                child: _image == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add_a_photo),
                    Text('Agregar foto',style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
                  ],
                )
                    : Image.file(_image,fit: BoxFit.fitWidth,),


              ),
            ),

            SizedBox(
              height: 50.0,
            ),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                  icon: Icon(Icons.location_on),
                  labelText:
                      '${widget.currentPosition.latitude},${widget.currentPosition.longitude}'),
            ),

            SizedBox(
              height: 50.0,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                icon: Icon(Icons.assignment),
                labelText:'Notas',

              ),
              onChanged: (val) => _notas = val,
            ),

          ],
        )
      ): Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

