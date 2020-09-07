import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';


abstract class BaseAuth {
  Future<FirebaseUser> getUser();
  Future logout();
  Future<FirebaseUser> loginUser(String email, String password);
  Future<FirebaseUser> signUpUser(String email, String password);
  Future<void> resetPassword(String email);
}

class Auth  implements BaseAuth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  final firebaseMessaging = new FirebaseMessaging();

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  // wrapping the firebase calls
  Future logout() async {
    var result = FirebaseAuth.instance.signOut();
    return result;
  }

  Future<FirebaseUser> loginUser(String email, String password) async {

    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await databaseReference.child('usuarios').child(result.user.uid).once().then((data) async {
        if(data.value != null && data.value['informacion'] != null){
          if(data.value['informacion']['correo'] != result.user.email){
            await databaseReference.child('usuarios').child(result.user.uid).child('informacion').child('correo').set(email);
          }

          firebaseMessaging.getToken().then((token) async {
            if( data.value['informacion']['fcm_token'] != token)
            {
              await databaseReference.child('usuarios').child(result.user.uid).child('informacion').child('fcm_token').set(token);
            }
          });
        }
        else
          {
            await databaseReference.child('usuarios').child(result.user.uid).child('informacion').child('correo').set(email);

            firebaseMessaging.getToken().then((token) async {
              await databaseReference.child('usuarios').child(result.user.uid).child('informacion').child('fcm_token').set(token);

            });
          }


      });

      return result.user;
    }  catch (e) {
      throw new AuthException(e.toString(), e.toString());
    }
  }

  Future<FirebaseUser> signUpUser(String email, String password) async {
    try {
      var result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);


      firebaseMessaging.getToken().then((token){
        databaseReference.child('usuarios').child(result.user.uid).child('informacion').set({
          'fcm_token':token,
          'correo': email
        }).then((data) {
          return result.user;

        });
      });


    }  catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

}
