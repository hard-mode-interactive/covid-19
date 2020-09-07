import 'package:covidtracker/utilities/flutter_youtube.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../utilities/screenSize.dart';


class ConsejosPage extends StatefulWidget {
  ConsejosPage({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _ConsejosPageState createState() => _ConsejosPageState();
}

class _ConsejosPageState extends State<ConsejosPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  bool _loading = true;


  void playYoutubeVideo(String videoUrl) {
    FlutterYoutube.playYoutubeVideoByUrl(
      apiKey: "AIzaSyAwr579cdq1ITdDEq3JhDqZPhQqxMiUJxY",
      videoUrl: videoUrl,
    );
  }

  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('consejos');

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
          title: Text('CONSEJOS UTILES',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        ),
        body: !_loading ?  StreamBuilder(
          stream: _firebaseRef.onValue,
          builder: (context, snap) {

            if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

              Map data = snap.data.snapshot.value;
              List item = [];

              data.forEach((key, data) {
                var consejo = {
                  "key": key,
                  "nombre": data['nombre'],
                  "descripcion": data['descripcion'],
                  "contenido": data['contenido'],
                  "foto": data['foto'],
                  "video": data['video']
                };
                item.add(consejo);
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
                      leading: Icon(Icons.nature_people,color: Colors.greenAccent,),
                      title: Text('${item[index]['nombre']}'),
                      subtitle: Text('${item[index]['descripcion']}'),
                      onTap: item[index]['contenido'] != null ?  () {
                        return showDialog(
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                              title: Text('Informacion'),
                              content:SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      Text('${item[index]['contenido']}'),
                                      SizedBox(
                                        height: 25.0,
                                      ),
                                      item[index]['foto'] != null ? InkWell(
                                        onTap: (){
                                          return showDialog(
                                            builder: (context) {
                                              return  Container(
                                                  width: SizeConfig.screenWidth,
                                                  height: SizeConfig.screenHeight,

                                                  child: PhotoView(
                                                    imageProvider: NetworkImage(item[index]['foto']),
                                                  )
                                              );
                                            },
                                            context: context,
                                          );
                                        },
                                        child: Image.network(item[index]['foto'],fit: BoxFit.fill,
                                          loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text('Cargando imagen'),
                                                    SizedBox(
                                                      height: 25.0,
                                                    ),
                                                    CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null ?
                                                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                          : null,
                                                    ),
                                                  ],
                                                )
                                            );
                                          },
                                        ),
                                      ) : Container(),
                                      item[index]['video'] != null ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(25.0),
                                            border: Border.all(color: Colors.transparent)
                                        ),
                                        child: FlatButton(
                                          child: Text("Ver video",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          onPressed: (){
                                            playYoutubeVideo(item[index]['video'] );
                                          },
                                        ),
                                      ): Container()
                                    ],
                                  )
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
                      }: (){},
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
