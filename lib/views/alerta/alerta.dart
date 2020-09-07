
import 'package:covidtracker/utilities/screenSize.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertaPage extends StatefulWidget {
  AlertaPage({this.notification,this.currentUser});
  final  notification;
  final currentUser;
  @override
  _AlertaPageState createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  bool _loading = false;

  String _apiKey = 'AIzaSyDfR0lnQGsePV__FvE10ikntYrSukMuZWs';
  String url1;
  String url2;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _saved = false;

  String _title;
  String _date;
  Future<void> _launched;
  String id;

  final databaseReference = FirebaseDatabase.instance.reference();

  void _setMarkers(){
    print(widget.notification);
    setState(() {
      _loading = true;
    });


    setState(() {
      if(widget.notification['data'] != null){
        url1 = "http://maps.google.com/maps/api/staticmap?center=" + widget.notification['data']['lat1'] + "," + widget.notification['data']['long1'] + "&zoom=17&size=512x256&sensor=false&&markers=color:red%7Clabel:%7C${widget.notification['data']['lat1']},${widget.notification['data']['long1']}&key=${_apiKey}";
        url2 = "http://maps.google.com/maps/api/staticmap?center=" + widget.notification['data']['lat2'] + "," + widget.notification['data']['long2'] + "&zoom=17&size=512x256&sensor=false&&markers=color:red%7Clabel:%7C${widget.notification['data']['lat2']},${widget.notification['data']['long2']}&key=${_apiKey}";
        _title = widget.notification['data']['title'];
        _date = widget.notification['data']['date'];

      }
      else
        {
          url1 = "http://maps.google.com/maps/api/staticmap?center=" + widget.notification['lat1'] + "," + widget.notification['long1'] + "&zoom=17&size=512x256&sensor=false&&markers=color:red%7Clabel:%7C${widget.notification['lat1']},${widget.notification['long1']}&key=${_apiKey}";
          url2 = "http://maps.google.com/maps/api/staticmap?center=" + widget.notification['lat2'] + "," + widget.notification['long2'] + "&zoom=17&size=512x256&sensor=false&&markers=color:red%7Clabel:%7C${widget.notification['lat2']},${widget.notification['long2']}&key=${_apiKey}";
          _title = widget.notification['title'];
          _date = widget.notification['date'];

        }

    });

    setState(() {
      _loading = false;
    });
  }

  void _borrar(){
    showDialog(
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Covid-19 Tracker'),
              Divider(color: Colors.black26,)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Esta informacion solo debe ser eliminada si usted considera que esto es un error o si ya se realizo los respectivos analisis en un centro de tencion. Si continua la informacion sera borrada permanentemente'),
              SizedBox(height: 10.0,),
              Divider(color: Colors.black26,)
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed:  () async {
                Navigator.pop(context);

                setState(() {
                  _loading = true;
                });

                databaseReference.child('usuarios').child(widget.currentUser.uid).child('alertas').child(widget.notification['key']).remove();
                setState(() {
                  _loading = false;
                });
                Navigator.pop(context);

              },
              child: Text('Continuar',style: TextStyle(color: Colors.red),),
            ),
            FlatButton(
              onPressed:  (){
                Navigator.pop(context);
              },
              child: Text('Cancelar',style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
      context: context,
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setMarkers();
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);

        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.orange[700],
          iconTheme: IconThemeData(color: Colors.white),
          title: Text('ALERTA DE CONTAGIO COVID-19',style: TextStyle(color: Colors.white, fontSize: 2 * SizeConfig.safeBlockVertical),),

        ),

        body: !_loading ? SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(

              children: <Widget>[
                //Text(_title,style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 25.0,),
                Text('Una persona contagiada estuvo en el mismo lugar que usted en la fecha ${_date} por favor comunicarse urgentemente al 132 o escriba al correo covid19@minsal.gob.sv para recibir instrucciones'),
                SizedBox(
                  height: 50.0,
                ),
                Text('Usted estuvo aqui',style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  height: 150.0,
                  child: Image.network(url1)
                ),
                SizedBox(
                  height: 50.0,
                ),
                Text('La otra persona estuvo aqui',style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                    height: 150.0,
                    child: Image.network(url2)
                ),
                SizedBox(
                  height: 50.0,
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _launched = _makePhoneCall('tel:132');
                    });
                  },
                  child:  Container(
                    width: MediaQuery.of(context).size.width * .7,
                    height: 7 * SizeConfig.blockSizeVertical,
                    padding:
                    EdgeInsets.symmetric(vertical: 1 * SizeConfig.blockSizeVertical),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              offset: Offset(2, 4),
                              blurRadius: 5,
                              spreadRadius: 2)
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xfffbb448), Color(0xfff7892b)])),
                    child: Text(
                      'LLAMAR',
                      style: TextStyle(
                          fontSize: 2 * SizeConfig.safeBlockVertical, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(
                  height: 10.0,
                ),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 2 * SizeConfig.blockSizeVertical,
              ),
              alignment: Alignment.bottomCenter,
              child:  InkWell(
                onTap: () {
                 _borrar();
                },
                child: Text(
                  'ELIMINAR',
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 2 * SizeConfig.safeBlockVertical,
                      fontWeight: FontWeight.w600),
                ),
              )
            )
              ],
            ),
          ),
        ): Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

