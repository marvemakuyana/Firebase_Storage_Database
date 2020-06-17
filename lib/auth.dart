import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

 final FirebaseAuth _auth = FirebaseAuth.instance;
 final GoogleSignIn _googleSignIn = new GoogleSignIn();

 Future<bool> signOut() async {

   await _auth.signOut();
   return true;
 }

 Future<Null> ensureLoggedIn() async {
   FirebaseUser firebaseUser = await _auth.currentUser();
   assert(firebaseUser != null);
   assert(firebaseUser.isAnonymous == false);
   print('We are logged into Firebase');
 }

 Future<bool> signInGoogle() async {

   GoogleSignInAccount googleUser =  await _googleSignIn.signIn();
   GoogleSignInAuthentication googleAuth = await googleUser.authentication;

   final AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,);
   final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    if(user != null && user.isAnonymous == false) {
      return true;
    } 
    return false;
 }

 Future<String> username() async {
   await ensureLoggedIn();
   FirebaseUser firebaseUser = await _auth.currentUser();
   return firebaseUser.uid;
 }