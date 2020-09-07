import 'package:covidtracker/services/auth.dart';
import 'package:covidtracker/utilities/screenSize.dart';
import 'package:covidtracker/views/autenticacion/iniciar_sesion/iniciar_sesion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:load/load.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({this.auth, this.login});
  final BaseAuth auth;
  final VoidCallback login;
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool obscurePass = true;
  bool autoValidate = false;

  bool validate (){
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      return true;
    }
    else
      {
        setState(() {
          autoValidate = true;
        });
        return false;
      }
  }
  void _register() async {

    if(validate()){
      var loading = await showLoadingDialog();

      try {
        FirebaseUser result =
            await widget.auth.signUpUser(_email, _password);
        loading.dismiss();

        Navigator.pop(context);
        widget.login();
      } on AuthException catch (error) {
        loading.dismiss();

        return _buildErrorDialog(context, error.message);
      } on Exception catch (error) {
        loading.dismiss();

        return _buildErrorDialog(context, error.toString());
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                autovalidate: autoValidate,
                child: Container(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10 * SizeConfig.blockSizeVertical ,
                        ),
                        SizedBox(
                          height: 155.0,
                          child: Image.asset(
                            "assets/logo_covid.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 45.0),
                        emailField(),
                        SizedBox(height: 25.0),
                        passwordField(),

                        SizedBox(height: 20.0),
                        submitButton(),
                        SizedBox(
                          height: 15.0,
                        ),

                        alreadyHaveAnAccount()
                      ]),
                )),
          ),
        )
    );
  }

  Widget emailField(){
    return Container(
      height: 10 * SizeConfig.blockSizeVertical,
      margin: EdgeInsets.symmetric(
        vertical: 1 * SizeConfig.blockSizeVertical,
      ),
      child: Container(
        height: 5 * SizeConfig.blockSizeVertical,
        child: TextFormField(
          obscureText: false,
          style: style,
          validator: (val){
            if(val.length < 3){
              return "Este no es un coreo valido";
            }
            else if(!val.contains('@')){
              return "Este no es un coreo valido";
            }
            else
            {
              return null;
            }
          },
          onSaved: (val) => _email = val,
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
        ),
      ),
    );
  }

  Widget passwordField(){
    return Container(
      height: 10 * SizeConfig.blockSizeVertical,
      margin: EdgeInsets.symmetric(
        vertical: 1 * SizeConfig.blockSizeVertical,
      ),
      child: Container(
        height: 5 * SizeConfig.blockSizeVertical,
        child: TextFormField(
          obscureText: obscurePass,
          style: style,
          onSaved: (val) => _password = val,
          validator: (val){
            if(val.length < 6){
              return "Al menos 6 caracteres";
            }
            else
              {
                return null;
              }
          },
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
      ),
    );
  }

  Widget submitButton(){
    return InkWell(
      onTap: _register,
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
          'Registrarse',
          style: TextStyle(
              fontSize: 2 * SizeConfig.safeBlockVertical, color: Colors.white),
        ),
      ),
    );
  }

  Widget alreadyHaveAnAccount(){
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 2 * SizeConfig.blockSizeVertical,
      ),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Ya tienes una cuenta?',
            style: TextStyle(
                fontSize: 2 * SizeConfig.safeBlockVertical,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Entra',
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


  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }
}
