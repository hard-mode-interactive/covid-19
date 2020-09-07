import 'package:covidtracker/services/auth.dart';
import 'package:covidtracker/utilities/screenSize.dart';
import 'package:covidtracker/views/autenticacion/forgot_password/forgot_password.dart';
import 'package:covidtracker/views/autenticacion/registrarse/registrarse.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:load/load.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.login});
  final BaseAuth auth;
  final VoidCallback login;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  bool obscurePass = true;


  _error(String error) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Covid-19 Tracker'),
              Divider(
                color: Colors.black26,
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(error),
              SizedBox(
                height: 10.0,
              ),
              Divider(
                color: Colors.black26,
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
            color: Colors.white,
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(child: _formulario()))
    );
  }

  Widget _formulario() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10 * SizeConfig.blockSizeVertical,
                ),
                _logo(),
                SizedBox(height: 75.0),

                _campoCorreo(),
                SizedBox(height: 10.0),
                _campoContrasena(),

                _forgotPassword(),
                SizedBox(
                  height: 15.0,
                ),
                _botonEntrar(context),
                SizedBox(
                  height: 15.0,
                ),
                _createAccountLabel(),

              ]),
        ));
  }

  Widget _logo() {
    return SizedBox(
      height: 20 * SizeConfig.blockSizeVertical,
      child: Image.asset(
        "assets/logo_covid.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _campoCorreo() {
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
              onSaved: (value) => _email = value,
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

  Widget _campoContrasena() {
    return Container(
        height: 10 * SizeConfig.blockSizeVertical,
        margin: EdgeInsets.symmetric(
          vertical: 1 * SizeConfig.blockSizeVertical,
        ),
        child: Container(
          height: 5 * SizeConfig.blockSizeVertical,
          child: TextFormField(
            obscureText: obscurePass,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
            validator: (val) => val.length < 6
                ? 'La contraseña debe tener al menos 6 caracteres'
                : null,
            onSaved: (value) => _password = value,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    20.0,
                    SizeConfig.blockSizeVertical * 3,
                    20.0,
                    SizeConfig.blockSizeVertical * 3),
                hintText: "Contraseña",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0)),
              suffixIcon: IconButton(
                onPressed: (){
                  setState(() {
                    obscurePass = !obscurePass;
                  });
                },
                icon: obscurePass ? Icon(Icons.lock) : Icon(Icons.lock_open),
              )
            ),
          ),
        ));
  }

  Widget _forgotPassword(){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ForgotPasswordPage(auth: widget.auth,)
        ));
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2 * SizeConfig.blockSizeVertical),
        alignment: Alignment.centerRight,
        child: Text('Olvido su contraseña ?',
            style:
            TextStyle(fontSize: 1.5 * SizeConfig.safeBlockVertical, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _botonEntrar(BuildContext context) {
    return InkWell(
      onTap: () async {
        final form = _formKey.currentState;
        form.save();

        if (form.validate()) {

          var loading = await showLoadingDialog();

          try {
            FirebaseUser result =
                await widget.auth.loginUser(_email, _password);
            loading.dismiss();

            widget.login();

          } on AuthException catch (error) {
            loading.dismiss();
            _error(error.message);
          } on Exception catch (error) {
            loading.dismiss();

            _error(error.toString());
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
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
          'Entrar',
          style: TextStyle(
              fontSize: 2 * SizeConfig.safeBlockVertical, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 2 * SizeConfig.blockSizeVertical,
      ),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No tienes una cuenta?',
            style: TextStyle(
                fontSize: 2 * SizeConfig.safeBlockVertical,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPage(
                            auth: widget.auth,
                            login: widget.login,
                          )));
            },
            child: Text(
              'Registrate',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 2 * SizeConfig.safeBlockVertical,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}
