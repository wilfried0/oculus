import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oculus/screens/map.dart';
import 'package:oculus/utils/colors.dart';
import 'package:oculus/utils/constantes.dart';
import 'package:url_launcher/url_launcher.dart';

class Recap extends StatefulWidget {
  @override
  _RecapState createState() => _RecapState();
}

class _RecapState extends State<Recap> {
  bool isLoading = false, isEmpty = false, isError = false;
  List data;
  List<String> imeis;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnection();
  }

  @override
  void dispose(){
    super.dispose();
  }


  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        isLoading = true;
      });
      this.getData();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isLoading = true;
      });
      this.getData();
    } else {
      ackAlert(context, -1, null);
    }
  }


  getData() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await client.getUrl(Uri.parse("$BaseUrl/all"));
    request.headers.set('Accept', 'application/json');
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print(response.statusCode);
    print(reply);
    if(response.statusCode == 200){
      if(reply.isEmpty){
        setState(() {
          isLoading = false;
          isEmpty = true;
        });
      }else{
        setState(() {
          isLoading = false;
          data = json.decode(reply);
        });
      }
    }else{
      print(response.statusCode);
      setState(() {
        isLoading = false;
      });
      showInSnackBar("Service indisponible!", _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Expanded(
                child:data == null?Center(child: CupertinoActivityIndicator(radius: 30,)):
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: ListView.builder(
                      itemCount: data == null?0:data.length,
                      itemBuilder: (BuildContext context, int i){
                        //ville, sinistre, description, image1, image2, latitude, longitude, voice, phone, imei, created_at
                        var ville = data[i]['ville'];
                        var sinistre = data[i]['incident'];
                        var description = data[i]['description'];
                        var latitude = data[i]['latitude'];
                        var longitude = data[i]['longitude'];
                        var phone = data[i]['phone'];
                        var _imeis = data[i]['multiImei'] as List;
                        imeis = new List();
                        for(int i=0; i<_imeis.length; i++){
                          imeis.add(_imeis[i]['imei']);
                        }
                        var created_at = data[i]['created_at'];
                        var image1 = data[i]['image1'];
                        var image2 = data[i]['image2'];
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 30.0),
                                _buildDate(created_at),
                                SizedBox(
                                  height: 20.0,
                                ),
                                _buildTown(ville),
                                SizedBox(
                                  height: 20.0,
                                ),

                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Latitude: $latitude", style: TextStyle(
                                            color: BLANC
                                        ),),
                                        Text("Longitude: $longitude", style: TextStyle(
                                            color: BLANC
                                        ),),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                        icon: Icon(LineIcons.map_marker, color: BLANC,size: 30,),
                                        onPressed: () =>
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(latitude: double.parse(latitude), longitude: double.parse(longitude))))
                                    )
                                  ],
                                ),

                                SizedBox(
                                  height: 20.0,
                                ),
                                _buildSinister(sinistre),
                                SizedBox(
                                  height: 20.0,
                                ),
                                _buildDescription(description),
                                SizedBox(
                                  height: 20.0,
                                ),
                                for ( String value in imeis )
                                  _buildImeis(imeis, imeis.indexOf(value)),

                                phone == null?Container():InkWell(
                                  onTap: (){
                                    launch('tel:$phone');
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, left: 30, right: 30),
                                    child: Container(
                                      height: Hchamp,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: BLANC,
                                        border: Border.all(
                                          color: BLANC,
                                          width: 1.5
                                        )
                                      ),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 20, right: 10),
                                              child: Icon(Icons.phone, color: Color(0xFF527DAA),),
                                            ),
                                            Text("$phone", style: TextStyle(color: Color(0xFF527DAA), fontWeight: FontWeight.bold, fontFamily: 'OpenSans'),),
                                          ],
                                        )
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 20.0,
                                ),
                                image1 == null?Container():_buildPicture(0, image1, image2),
                                SizedBox(
                                  height: 20.0,
                                ),
                                image2 == null?Container():_buildPicture(1, image1, image2),
                              ],
                            ),
                          ),
                        ),
                      );
                  }
                ),
                    )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTown(String ville) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ville',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          //height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              enabled: false,
              maxLines: null,
              controller:TextEditingController(text: ville),
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Description détaillée du sinistre',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSinister(String sinistre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Incident',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          //height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              enabled: false,
              maxLines: null,
              controller:TextEditingController(text: sinistre),
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Description détaillée du sinistre',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Description de l\'incident et du lieu',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          //height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              enabled: false,
              maxLines: null,
              controller:TextEditingController(text: description),
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Description détaillée du sinistre',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDate(String date) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: kBoxDecorationStyle,
      height: 40.0,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: Center(
          child: TextFormField(
            enabled: false,
            maxLines: null,
            controller: TextEditingController(text: date),
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Date & heure',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPicture(int q, String image1, String image2){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q == 0?'Pièce N°1':'Pièce N°2',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          child: Image.network(q == 0?image1:image2, frameBuilder: (context, _build, i, t){
            print("************************** l'entier: $i");
            print("************************** le boolean: $t");
            isError = t;
            return Container();
          },),
        )
      ],
    );
  }

  Widget _buildImeis(List<String> content, int position){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'IMEI N°${position + 1}',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              controller: TextEditingController(text: "${content[position]}"),
              enabled: false,
              maxLines: null,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Description détaillée du sinistre',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}
