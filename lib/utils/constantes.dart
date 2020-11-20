import 'dart:ui';
import 'package:flutter/material.dart';

final double Ttext = 12.0;
final double bordure = 1.5;
final double Hchamp = 35;
final double radius = 25;

//"http://74.208.183.205:8086/corebanking/rest";
final BaseUrl = "http://192.168.100.10:9098/api/oculus/";


final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

class Imei{
  final String imei;

  Imei({this.imei});

  Imei.fromJson(Map<String, dynamic> json)
      : imei = json['imei'];

  Map<String, dynamic> toJson() =>
      {
        "imei":imei
      };
}

class Data{
  final String phone;
  final String latitude;
  final String longitude;
  final String ville;
  final String incident;
  final String description;
  final String voice;
  final String created_at;
  final String image1;
  final String image2;
  final String imei;
  final List<Imei> multiImei;
  final bool callMe;

  Data({this.phone, this.latitude, this.longitude, this.ville, this.incident, this.description, this.voice, this.created_at, this.imei, this.multiImei, this.image1, this.image2, this.callMe});

  Data.fromJson(Map<String, dynamic> json)
      : phone = json['phone'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        ville = json['ville'],
        incident = json['incident'],
        description = json['description'],
        voice = json['voice'],
        created_at = json['created_at'],
        imei = json['imei'],

        multiImei = List<Imei>.from(json["multiImei"].map((x) => Imei.fromJson(x))),
        //multiImei = json['multiImei'],
        image1 = json['image1'],
        image2 = json['image2'],
        callMe = json['callMe'];

  Map<String, dynamic> toJson() =>
      {
        "phone":phone,
        "latitude": latitude,
        "longitude": longitude,
        "ville": ville,
        "incident": incident,
        "description": description,
        "voice": voice,
        "created_at": created_at,
        "imei": imei,
        "multiImei": multiImei,
        "image1": image1,
        "image2": image2,
        "callMe": callMe
      };
}

void showInSnackBar(String value, GlobalKey<ScaffoldState> scaffoldKey) {
  scaffoldKey.currentState.showSnackBar(
      new SnackBar(content: new Text(value,style:
      TextStyle(
          color: Colors.white,
          fontSize: Ttext+3.0
      ),
        textAlign: TextAlign.center,),
        backgroundColor: Color(0xFF527DAA),
        //duration: Duration(seconds: val),
      ));
}

Future<void> ackAlert(BuildContext context, int q, Function getImage) {
  print("voilà $q");
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(q == -1?'Oops!':'Caméra/Galerie'),
        content: Text(q == -1?'Vérifier votre connexion internet.':'Prendre l\'image depuis la Galerie ou la caméra'),
        actions: <Widget>[
          FlatButton(
            child: Text(q == -1?'Ok':'Galerie'),
            onPressed: () {
              if(q == 1){//Galerie pour image1
                Navigator.of(context).pop();
                getImage(1);
              }else if(q == -1){
                Navigator.of(context).pop();
              }else if(q == 2){//Galery pour image2
                Navigator.of(context).pop();
                getImage(2);
              }
            },
          ),
          q == -1?Container():FlatButton(
            child: Text('Caméra'),
            onPressed: () {
              if(q == 1){//Caméra pour l'image1
                Navigator.of(context).pop();
                getImage(3);
              }else if(q == 2){//Caméra pour l'image2
                Navigator.of(context).pop();
                getImage(4);
              }
            },
          ),
          q == -1?Container():FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, child: Text('Annuler')
          )
        ],
      );
    },
  );
}