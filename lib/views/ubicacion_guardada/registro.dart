import 'package:covidtracker/services/guardar_ubicacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utilities/screenSize.dart';

class RegistroPage extends StatefulWidget {
  RegistroPage({this.currentUser, this.registro});
  final FirebaseUser currentUser;
  final registro;
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  BaseGuardarUbicacion _ubicacion = new GuardarUbicacion();
  bool _loading = false;
  final databaseReference = FirebaseDatabase.instance.reference();

  bool _isEditing = false;
  String _nombre;
  String _notas;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          if(!_isEditing)
            {
              _settingModalBottomSheet(context);

            }
          else
            {
              setState(() {
                _isEditing = false;
              });
            }
        },
        child: !_isEditing ?  new Icon(
          Icons.menu,
          color: Colors.white,
        ): Icon(Icons.cancel, color: Colors.white,),
      ),
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'UBICACION GUARDADA',
          style: TextStyle(
              color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),
        ),
        actions: <Widget>[
          _isEditing ? IconButton(
            onPressed: () async{
              setState(() {
                _loading = true;
              });
              await _ubicacion.actualizarUbicacion(widget.currentUser,widget.registro['key'],_nombre, _notas,);
           Navigator.pop(context);
            },
            icon: Icon(Icons.save,color: Colors.white,),
          ): Container()
        ],

      ),
      body: !_loading
          ? SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  !_isEditing
                      ? TextField(
                          enabled: false,
                          decoration: InputDecoration(
                              icon: Icon(Icons.subject),
                              labelText: widget.registro['nombre'] != null
                                  ? widget.registro['nombre']
                                  : ''),
                        )
                      : _editarNombre(),
                  SizedBox(
                    height: 50.0,
                  ),
//                  InkWell(
//                    onTap: widget.registro['foto'] != null
//                        ? () {
//                            return showDialog(
//                              builder: (context) {
//                                return AlertDialog(
//                                  title: Text('Foto'),
//                                  content: Image.network(
//                                    widget.registro['foto'],
//                                    fit: BoxFit.fitWidth,
//                                  ),
//                                  actions: <Widget>[
//                                    FlatButton(
//                                        child: Text('Cerrar'),
//                                        onPressed: () {
//                                          Navigator.of(context).pop();
//                                        })
//                                  ],
//                                );
//                              },
//                              context: context,
//                            );
//                          }
//                        : null,
//                    child: Container(
//                        width: 400.0,
//                        height: 200.0,
//                        decoration: BoxDecoration(
//                            border: Border.all(color: Colors.black12),
//                            borderRadius: BorderRadius.circular(5.0)),
//                        child: widget.registro['foto'] != null
//                            ? Image.network(
//                                widget.registro['foto'],
//                                fit: BoxFit.fitWidth,
//                              )
//                            : Center(
//                                child: Icon(Icons.image),
//                              )),
//                  ),
//                  SizedBox(
//                    height: 50.0,
//                  ),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                        icon: Icon(Icons.location_on),
                        labelText: widget.registro['location'] != null
                            ? '${widget.registro['location']['lat']}, ${widget.registro['location']['long']}'
                            : ''),
                  ),

                  SizedBox(
                    height: 50.0,
                  ),

                  TextFormField(
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    decoration: InputDecoration(
                      icon: Icon(Icons.directions),
                      labelText: widget.registro['direccion']
                    ),
                  ),

                  SizedBox(
                    height: 50.0,
                  ),

                  !_isEditing
                      ? TextFormField(
                          enabled: false,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            icon: Icon(Icons.assignment),
                            labelText: widget.registro['notas'] != null
                                ? widget.registro['notas']
                                : '',
                          ),
                        )
                      : _editarNotas(),
                ],
              ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _editarNombre() {
    return TextField(
      onChanged: (val) => _nombre = val,
      autofocus: true,
      decoration: InputDecoration(
        icon: Icon(Icons.subject),
        labelText:'Nombre',
      ),
    );
  }

  Widget _editarNotas() {
    return TextFormField(
      keyboardType: TextInputType.text,
      onChanged: (val) => _notas = val,
      decoration: InputDecoration(
        icon: Icon(Icons.assignment),
        labelText:'Notas',



      ),
    );
  }



  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.edit),
                    title: new Text('Editar'),
                    onTap: (){
                      setState(() {
                        _isEditing = true;
                        _nombre = widget.registro['nombre'];
                        _notas = widget.registro['notas'];
                      });
                      Navigator.pop(context);

                    }),
                new ListTile(
                  leading: new Icon(Icons.delete),
                  title: new Text('Eliminar'),
                  onTap: () async {
                    Navigator.pop(context);
                    _borrar();
                  },
                ),
              ],
            ),
          );
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
              Text('Esta seguro?'),
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

                await _ubicacion.eliminarUbicacion(
                    widget.currentUser,
                    widget.registro['key'],
                    widget.registro['foto'] != null
                        ? widget.registro['foto']
                        : null);
                setState(() {
                  _loading = true;
                });
                Navigator.pop(context);

              },
              child: Text('Eliminar'),
            ),
            FlatButton(
              onPressed:  (){
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
      context: context,
    );
  }
}
