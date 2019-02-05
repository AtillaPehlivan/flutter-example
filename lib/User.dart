import 'dart:io';
import 'package:flighttickets/main.dart';

import 'ChoiceChip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flighttickets/CustomAppBar.dart';
import 'package:flighttickets/CustomShapeClipper.dart';
import 'package:flighttickets/flight_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Photos.dart';
import 'PhotosCard.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;




Future<bool> _hasUser() async{
  final FirebaseUser currentUser = await _auth.currentUser();
  print(!currentUser.isAnonymous);
  return !currentUser.isAnonymous;
}




class User extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomAppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            UserScreenTopBar(),
          ],
        ),
      ),
    );
  }
}

class loginUser{
  String name;
  String url;
  bool hasLogin =false;
  loginUser(String name,String url,bool s);
}



class UserScreenTopBar extends StatefulWidget {
  @override
  _UserScreenTopBarState createState() => _UserScreenTopBarState();
}

class _UserScreenTopBarState extends State<UserScreenTopBar> {
  @override


  loginUser LoginUser = new loginUser("null","null",false);
  void initState() {
    state = FlowState.Popular;
    // TODO: implement initState
    super.initState();
    _handleSignIn();

  }

  String userName,userPhoto;
  bool hasUser=false;
  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    setState(() {
      userName = user.displayName;
      userPhoto=user.photoUrl;
      hasUser = true;
    });
    print("signed in " + user.displayName);
  }
  Future<bool> _handleSignOut() async {
    await _googleSignIn.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 400.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [firstColor, secondColor],
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                Container(),
                SizedBox(
                  height: 30.0,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 100.0,
                        width: 100.0,
                        child: CachedNetworkImage(
                          imageUrl: hasUser == true ? userPhoto :  'https://firebasestorage.googleapis.com/v0/b/artisfy-4c40e.appspot.com/o/994628-200.png?alt=media&token=cb00e394-3898-4970-87ab-28694f6e81c0',
                          fit: BoxFit.cover,
                          fadeInDuration: Duration(milliseconds: 500),
                          fadeInCurve: Curves.easeIn,
                          placeholder: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    hasUser == true  ?
                    'Giriş Yapıldı \n Merhaba ' + userName : "Giriş Yapılmamış Hemen giriş yap",
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                hasUser ? RaisedButton(
                  child: const Text('SignOut Google'),
                  elevation: 4.0,
                  onPressed: () {
                    setState(() {
                      _handleSignOut();
                    });
                    // Perform some action
                  },
                ) :
                new RaisedButton(
                  child: const Text('Connect with Google'),
                  elevation: 4.0,
                  onPressed: () {
                    setState(() {
                      _handleSignIn();
                    });
                    // Perform some action
                  },
                ),

              ],
            ),
          ),
        )
      ],
    );
  }





}







