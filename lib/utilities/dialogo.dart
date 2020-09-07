import 'package:flutter/material.dart';


class Dialogo extends StatelessWidget {
  Dialogo({this.title,this.content,this.metodo,this.boton});
  final title;
  final content;
  final VoidCallback metodo;
  final String boton;

  @override
  Widget build(BuildContext context) {
     showDialog(
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title),
              Divider(color: Colors.black26,)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(content),
              SizedBox(height: 10.0,),
              Divider(color: Colors.black26,)
            ],
          ),
          actions: <Widget>[

           metodo != null ? FlatButton(
              onPressed: metodo,
              child: Text(boton),
            ) : null,

            FlatButton(
              onPressed:  (){
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
      context: context,
    );
  }
}
