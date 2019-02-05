import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flighttickets/CustomAppBar.dart';
import 'package:flighttickets/CustomShapeClipper.dart';
import 'package:flighttickets/flight_list.dart';
import 'package:flutter/material.dart';
import 'Photos.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class PhotosCard extends StatelessWidget {
  final Photos photo;

  PhotosCard({this.photo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 210.0,
                  width: 160.0,
                  child: CachedNetworkImage(
                    imageUrl: '${photo.url}',
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeInCurve: Curves.easeIn,
                    placeholder: Center(child: CircularProgressIndicator()),
                  ),
                ),
                Positioned(
                  left: 0.0,
                  bottom: 0.0,
                  width: 160.0,
                  height: 60.0,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black,
                              Colors.black.withOpacity(0.1),
                            ])),
                  ),
                ),
                Positioned(
                  left: 10.0,
                  bottom: 10.0,
                  right: 10.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${photo.title}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18.0),
                          ),
                          Text(
                            '${photo.date}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 14.0),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child:
                        Row(
                          children: <Widget>[
                            IconButton(icon: new Icon(Icons.favorite,color: Colors.red,size: 30),
                              onPressed: (){
                                photo.updateLike();
                              },
                            ),
                            Text(
                              '${photo.like}',
                              style: TextStyle(fontSize: 14.0, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 5.0,
              ),
//              Text(
//                '${formatCurrency.format(photo.newPrice)}',
//                style: TextStyle(
//                    color: Colors.black,
//                    fontWeight: FontWeight.bold,
//                    fontSize: 14.0),
//              ),
              SizedBox(
                width: 5.0,
              ),
//              Text(
//                "(${formatCurrency.format(photo.oldPrice)})",
//                style: TextStyle(
//                    color: Colors.grey,
//                    fontWeight: FontWeight.normal,
//                    fontSize: 12.0),
//              ),
            ],
          )
        ],
      ),
    );
  }
}