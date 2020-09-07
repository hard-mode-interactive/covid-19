import 'package:covidtracker/services/auth.dart';
import 'package:covidtracker/utilities/screenSize.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  final BaseAuth auth;
  ForgotPasswordPage({this.auth});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  bool autoValidate = false;

  String email;

  bool validate() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return true;
    } else {
      setState(() {
        autoValidate = true;
      });
      return false;
    }
  }

  void _resetPassword() async {
    if(validate()){
      widget.auth.resetPassword(email);
      showDialog(
        context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text("Listo!"),
              content: Text("Se ha enviado un enlace a su correo"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Aceptar"),
                )
              ],
            );
          });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 5 * SizeConfig.blockSizeHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _title(),
                SizedBox(
                  height: 2.5 * SizeConfig.blockSizeVertical,
                ),
                Text(
                  "Se enviara un correo con el enlace de recuperacion",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                SizedBox(
                  height: 2.5 * SizeConfig.blockSizeVertical,
                ),
                form(),
                SizedBox(
                  height: 2.5 * SizeConfig.blockSizeVertical,
                ),
                _submitButton(),
                SizedBox(
                  height: 2.5 * SizeConfig.blockSizeVertical,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _cancel(),
          ),
        ],
      ),
    )));
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Covid-19 Tracker',
        style: TextStyle(
          fontSize: 3 * SizeConfig.safeBlockVertical,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _email() {
    return Container(
        height: 10 * SizeConfig.blockSizeVertical,
        margin: EdgeInsets.symmetric(
          vertical: 1 * SizeConfig.blockSizeVertical,
        ),
        child: Container(
            height: 5 * SizeConfig.blockSizeVertical,
            child: TextFormField(
              obscureText: false,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
              validator: (val) =>
                  !val.contains('@') ? 'Este no es un correo valido' : null,
              onSaved: (value) => email = value,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                      20.0,
                      SizeConfig.blockSizeVertical * 3,
                      20.0,
                      SizeConfig.blockSizeVertical * 3),
                  hintText: "Correo",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0))),
            )));
  }

  Widget form() {
    return Form(key: _formKey, autovalidate: autoValidate, child: _email());
  }

  Widget _submitButton() {
    return InkWell(
      onTap: _resetPassword,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 5 * SizeConfig.blockSizeVertical,
        padding:
            EdgeInsets.symmetric(vertical: 1 * SizeConfig.blockSizeVertical),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
          "Enviar",
          style: TextStyle(
              fontSize: 2 * SizeConfig.safeBlockVertical, color: Colors.white),
        ),
      ),
    );
  }

  Widget _cancel() {
    return Container(
        margin: EdgeInsets.symmetric(
          vertical: 2 * SizeConfig.blockSizeVertical,
        ),
        alignment: Alignment.bottomCenter,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancelar',
            style: TextStyle(
                color: Color(0xfff79c4f),
                fontSize: 2.5 * SizeConfig.safeBlockVertical,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}
