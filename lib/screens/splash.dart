import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oculus/screens/home.dart';
import 'package:oculus/utils/colors.dart';
import 'package:oculus/utils/constantes.dart';


class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), onDoneLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: new Image.asset('assets/images/logo.png'),
          ),

          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height-40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copyright, color: GRIS,),
                Text("Copyright 2020", style: TextStyle(
                    color: GRIS,
                    fontSize: Ttext,
                    fontStyle: FontStyle.italic
                ),),
              ],
            ),
          )
        ],
      ),
    );
  }


  onDoneLoading() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
  }
}
