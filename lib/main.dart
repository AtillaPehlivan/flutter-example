import 'dart:io';
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
import 'User.dart' as userClass;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
      name: 'com.example.flighttickets',
      options:  FirebaseOptions(
              googleAppID: '1:925278888505:android:8658d2b8af672428',
              apiKey: 'AIzaSyCw4KW82ovg_trmKNnhQbf9jnIIZHDRoo8',
              databaseURL: 'https://artisfy-4c40e.firebaseio.com/',
            ));


  runApp(MaterialApp(
    title: 'Artisfy',
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    theme: appTheme,
  ));
}

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFFEF772C);


enum FlowState {
  New,
  Popular,
}



FlowState state =FlowState.Popular;

ThemeData appTheme =
    ThemeData(primaryColor: Color(0xFFF3791A), fontFamily: 'Oxygen');

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();


List<String> locations = List();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomAppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            HomeScreenTopPart(),
            BottomBarPopular(),
            BottomBarNew(),
          ],
        ),
      ),
    );
  }
}

const TextStyle dropDownLabelStyle = TextStyle(color: Colors.white, fontSize: 16.0);
const TextStyle dropDownMenuItemStyle = TextStyle(color: Colors.black, fontSize: 16.0);

final _searchFieldController = TextEditingController();

class HomeScreenTopPart extends StatefulWidget {
  @override
  _HomeScreenTopPartState createState() => _HomeScreenTopPartState();
}

class _HomeScreenTopPartState extends State<HomeScreenTopPart> {
  var selectedLocationIndex = 0;
  var isFlightSelected = true;

  var listViewTitleText = "Popular Items";
  String photosCount = "0";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  File _image;
  File croppedUserImage;

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
      toolbarTitle: "Resim Düzenle"
    );
    return croppedFile;
  }
  String u_name;
  Future<String> getUserName() async{

      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      setState(() {
        u_name = user.displayName;
      });

  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    croppedUserImage = await _cropImage(_image);
    DateTime now = new DateTime.now();
    var datestamp = new DateFormat("yyyyMMdd'T'HHmmss");
    String currentdate = datestamp.format(now);
    final StorageReference firebaseSorageRef = FirebaseStorage.instance.ref().child('$currentdate.jpg');
    final StorageUploadTask task = firebaseSorageRef.putFile(croppedUserImage);
    String url = await (await task.onComplete).ref.getDownloadURL();
    showLocalNotification();
    var datestampforUser_mm = new DateFormat("MM");
    var datestampforUser_dd = new DateFormat("dd");
    String str_datestampforUser_mm = datestampforUser_mm.format(now);
    String str_datestampforUser_dd = datestampforUser_dd.format(now);
    String fullDateForUsers = str_datestampforUser_dd + ' / ' +str_datestampforUser_mm;
    addPhoto(url,u_name.substring(0,6),fullDateForUsers);
  }

  @override
  void initState() {
    state = FlowState.Popular;


    // TODO: implement initState
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android  = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, IOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,onSelectNotification: onSelectNotification);

  }

  Future onSelectNotification(String payload)
  {
    showDialog(context: context,builder: (_)=>new AlertDialog(
      title: new Text('Notification'),
      content: new Text('Resminiz Yüklenmiştir.'),
    ));
  }

  showLocalNotification() async{
    var android = new AndroidNotificationDetails('channel id', 'channel NAME', 'channel DESCRIPTION');
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, ios);
    await flutterLocalNotificationsPlugin.show(0, 'Fotoğrafınız Yüklendi...', 'Fotoğraf işlemi için bekleniyor  ', platform);
  }
  
  addPhoto (String url,String name,String date ){

    Firestore.instance.collection('photos').add({
      'date':date,
      'title':name,
      'url':url,
      'like':0,
    });
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
                StreamBuilder(
                  stream:
                      Firestore.instance.collection('locations').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      addLocations(context, snapshot.data.documents);

                    return !snapshot.hasData
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: <Widget>[
                                IconButton(icon: new Icon(Icons.linked_camera,color: Colors.white),
                                onPressed: (){
                                  getUserName();
                                  getImage();
                                  },
                                ),

                                SizedBox(
                                  width: 16.0,
                                ),
//                                PopupMenuButton(
//                                  onSelected: (index) {
//                                    setState(() {
//                                      selectedLocationIndex = index;
//                                    });
//                                  },
//                                  child: Row(
//                                    children: <Widget>[
//                                      Text(
//                                        locations[selectedLocationIndex],
//                                        style: dropDownLabelStyle,
//                                      ),
//                                      Icon(
//                                        Icons.keyboard_arrow_down,
//                                        color: Colors.white,
//                                      )
//                                    ],
//                                  ),
//                                  itemBuilder: (BuildContext context) => _buildPopupMenuItem(),
//                                ),
                                Spacer(),
                                Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          );
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Amazing Filter Your Photo\nWith AI',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
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
                    child: TextField(
                      controller: _searchFieldController,
                      style: dropDownMenuItemStyle,
                      cursorColor: appTheme.primaryColor,
                      decoration: InputDecoration(
                        hintText: "Search",

                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 14.0),
                        suffixIcon: Material(
                          elevation: 2.0,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InheritedFlightListing(
                                            fromLocation: locations[
                                                selectedLocationIndex],
                                            toLocation:
                                                _searchFieldController.text,
                                            child: FlightListingScreen(),
                                          )));
                            },
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      child: Choicechip(
                          Icons.favorite, "Popular", isFlightSelected),
                      onTap: () {
                        setState(() {
                          state = FlowState.Popular;
                          isFlightSelected = true;
                          listViewTitleText = "Popular Items";
                        });
                        final snackBar = SnackBar(
                          content: Text('Popular Images'),
                          action: SnackBarAction(
                            label: 'Tamam',
                            onPressed: () {
                              // Some code to undo the change!
                            },
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      },
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      child:
                      Choicechip(Icons.access_time, "Hot", !isFlightSelected),
                      onTap: () {
                        setState(() {
                          isFlightSelected = false;
                          listViewTitleText = "Hot Items";
                          state = FlowState.New;
                        });
                        final snackBar = SnackBar(
                          content: Text('Hot Images'),
                          action: SnackBarAction(
                            label: 'Tamam',
                            onPressed: () {
                              // Some code to undo the change!
                            },
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }





}




List<PopupMenuItem<int>> _buildPopupMenuItem() {
  List<PopupMenuItem<int>> popupMenuItems = List();
  for (int i = 0; i < locations.length; i++) {
    popupMenuItems.add(PopupMenuItem(
      child: Text(
        locations[i],
        style: dropDownMenuItemStyle,
      ),
      value: i,
    ));
  }

  return popupMenuItems;
}



var viewAllStyle = TextStyle(fontSize: 14.0, color: appTheme.primaryColor);


class BottomBarPopular extends StatefulWidget {
  @override
  _BottomBarPopularState createState() => _BottomBarPopularState();
}

class _BottomBarPopularState extends State<BottomBarPopular> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  int CountPhotos=0;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Popular",
                    style: dropDownMenuItemStyle,
                  ),
                  Spacer(),
                  Text(
                    "VIEW ALL("+CountPhotos.toString()+")",
                    style: viewAllStyle,
                  ),
                ],
              ),
            ),
            Container(
              height: 240.0,
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('photos')
                      .orderBy('like',descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<DocumentSnapshot> snapshotss = snapshot.data.documents;
                    CountPhotos = snapshotss.length;
                    return !snapshot.hasData
                        ? Center(child: CircularProgressIndicator())
                        : _buildCitiesList(context, snapshot.data.documents);
                  }),
            ),
          ],
        )
    );
  }
}


class BottomBarNew extends StatefulWidget {
  @override
  _BottomBarNewState createState() => _BottomBarNewState();
}

class _BottomBarNewState extends State<BottomBarNew> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  int CountPhotos=0;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "New",
                    style: dropDownMenuItemStyle,
                  ),
                  Spacer(),
                  Text(
                    "VIEW ALL("+CountPhotos.toString()+")",
                    style: viewAllStyle,
                  ),
                ],
              ),
            ),
            Container(
              height: 240.0,
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('photos')
                      .orderBy('like',descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<DocumentSnapshot> snapshotss = snapshot.data.documents;
                    CountPhotos = snapshotss.length;
                    return !snapshot.hasData
                        ? Center(child: CircularProgressIndicator())
                        : _buildCitiesList(context, snapshot.data.documents);
                  }),
            ),
          ],
        )
    );
  }
}


Widget _buildCitiesList(BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
      itemCount: snapshots.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return PhotosCard(photo: Photos.fromSnapshot(snapshots[index]));
      });
}

class Location {
  final String name;

  Location.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        name = map['name'];

  Location.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}
addLocations(BuildContext context, List<DocumentSnapshot> snapshots) {
  for (int i = 0; i < snapshots.length; i++) {
    final Location location = Location.fromSnapshot(snapshots[i]);
    locations.add(location.name);
  }
}
final formatCurrency = NumberFormat.simpleCurrency();
