import 'package:flutter/material.dart';
import 'main.dart';
import 'User.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget {
  final List<BottomNavigationBarItem> bottomBarItems = [];
  int index=0;
  final bottomNavigationBarItemStyle =
      TextStyle(fontStyle: FontStyle.normal, color: Colors.black);

  CustomAppBar() {
    bottomBarItems.add(
      BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
          color: appTheme.primaryColor,
        ),
        title: Text("Main Page", style: bottomNavigationBarItemStyle.copyWith(color: appTheme.primaryColor)),
      ),
    );
//    bottomBarItems.add(
//      new BottomNavigationBarItem(
//        icon: new Icon(
//          Icons.favorite,
//          color: Colors.black,
//        ),
//        title: Text(
//          "Watchlist",
//          style: bottomNavigationBarItemStyle,
//        ),
//      ),
//    );
//    bottomBarItems.add(
//      new BottomNavigationBarItem(
//        icon: new Icon(
//          Icons.local_offer,
//          color: Colors.black,
//        ),
//        title: Text(
//          "Deals",
//          style: bottomNavigationBarItemStyle,
//        ),
//      ),
//    );
    bottomBarItems.add(
      new BottomNavigationBarItem(

        icon: new Icon(
          Icons.settings,
          color: Colors.black,
        ),
        title: Text(
          "Profil",
          style: bottomNavigationBarItemStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 15.0,
      child: BottomNavigationBar(
        currentIndex: index,
        onTap: (int index){

          index == 1 ?
          Navigator.push(context, MaterialPageRoute(builder: (context) => User()))
              :
          Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()));
        },
        items: bottomBarItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
