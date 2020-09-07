
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class BaseGuardarUbicacion {

  Future<DataSnapshot> guardar(FirebaseUser currentUser,Position currentPosition,String nombre, String notas, File _image);
  Future<DataSnapshot> eliminarUbicacion(FirebaseUser currentUser, String registro, String foto);
  Future<DataSnapshot> actualizarUbicacion(FirebaseUser currentUser, String key,String nombre, String notas);
}

class GuardarUbicacion implements BaseGuardarUbicacion  {

  final databaseReference = FirebaseDatabase.instance.reference();
  final storageReference = FirebaseStorage.instance.ref();
  var uuid = Uuid();

  File jsonFile;
  Directory dir;
  String fileName = "bitacora.json";
  bool fileExists = false;
  Map<String, dynamic> fileContent;


  Future<DataSnapshot> guardar(FirebaseUser currentUser,Position currentPosition,String nombre, String notas, File _image) async {

    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();
    final coordinates = new Coordinates(currentPosition.latitude,currentPosition.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(now);
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    var url;


        try {
      final connection = await InternetAddress.lookup('google.com');
      if (connection.isNotEmpty && connection[0].rawAddress.isNotEmpty) {

        getApplicationDocumentsDirectory().then((Directory directory) {
          dir = directory;

          jsonFile = new File(dir.path + "/" + fileName);
          fileExists = jsonFile.existsSync();
          if (fileExists){
            fileContent = jsonDecode(jsonFile.readAsStringSync());

            fileContent.forEach((key,value){

              databaseReference.child('usuarios').child(currentUser.uid).child('bitacora_lugares').child(key).set(value);
            });
            deleteFile(dir, fileName);
          }
        });



        if(_image != null){


          StorageUploadTask uploadTask = storageReference.child(currentUser.uid)
              .child('fotos').child(uuid.v4()).putFile(_image);


          StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

          url = await taskSnapshot.ref.getDownloadURL();

        }

        Map<String,dynamic> ubicacion = {

          'location': {
            'lat':'${currentPosition.latitude}',
            'long':'${currentPosition.longitude}'
          },
          'nombre':nombre,
          'notas':notas,
          'foto': url,
          'fecha': formattedDate,
          'timeStamp': timeStamp


        };



        databaseReference.child('usuarios').child(currentUser.uid).child('bitacora_lugares').child(uuid.v4()).set(ubicacion).then((val){

          return val;

        });
      }
    } on SocketException catch (_) {

          Map<String,dynamic> ubicacion = {

            '${uuid.v4()}':{
              'location': {
                'lat':'${currentPosition.latitude}',
                'long':'${currentPosition.longitude}'
              },
              'nombre':nombre,
              'direccion': '${first.addressLine}',
              'notas':notas,
              'foto': null,
              'fecha': formattedDate,
              'timeStamp': timeStamp
            }
          };

          getApplicationDocumentsDirectory().then((Directory directory) {
            dir = directory;

            jsonFile = new File(dir.path + "/" + fileName);
            fileExists = jsonFile.existsSync();
            if (fileExists){
              fileContent = jsonDecode(jsonFile.readAsStringSync());

              fileContent.addAll(ubicacion);

              writeToFile(fileContent);
            }
            else
              {
               createFile(ubicacion, dir, fileName);
              }
          });


        }




  }

  Future<DataSnapshot> actualizarUbicacion(FirebaseUser currentUser, String key,String nombre, String notas){

    Map<String,dynamic> ubicacion = {


      'nombre':nombre,
      'notas':notas

    };

    databaseReference.child('usuarios').child(currentUser.uid).child('bitacora_lugares').child(key).update(ubicacion).then((val){
      return val;
    });


  }
  
  Future<DataSnapshot> eliminarUbicacion(FirebaseUser currentUser, String key, String foto){

    if(foto != null){
      FirebaseStorage.instance.getReferenceFromUrl(foto).then((val){
        val.getPath().then((path){
          storageReference.child(path).delete().whenComplete((){
            databaseReference..child('usuarios').child(currentUser.uid).child('bitacora_lugares').child(key).remove().then((val){
              return val;
            });
          });
        });
      });



    }
    else
      {
        databaseReference..child('usuarios').child(currentUser.uid).child('bitacora_lugares').child(key).remove().then((val){
          return val;
        });
      }

  }

  void createFile(Map<String, dynamic> content, Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(jsonEncode(content));
  }

  void writeToFile(Map<String, dynamic> content) {

    if (fileExists) {
      Map<String, dynamic> jsonFileContent = jsonDecode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(jsonEncode(jsonFileContent));
    } else {
      createFile(content, dir, fileName);
    }

    fileContent = jsonDecode(jsonFile.readAsStringSync());
  }

  void deleteFile(Directory dir, String fileName){
    File file = new File(dir.path + "/" + fileName);
    file.deleteSync();
  }


}