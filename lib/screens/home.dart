import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:oculus/screens/recap.dart';
import 'package:oculus/utils/colors.dart';
import 'package:oculus/utils/constantes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http_parser/http_parser.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final picker = ImagePicker();
  bool galeryLoading = false, _hasSpeech = false, cameraLoading = false, callMe = false, isRecording = false, _isAvailable = false, _isListening = false, isLoading = false, isdescrip = false, isPhone = false, isTown = false, isSinister = false;
  String ville, sinistre, created_at, resultText = "",status, _currentLocaleId = 'fr_FR', outputText = '', description, image1, image2, latitude, longitude, voice, contact, imei;
  Position currentPosition, lastPosition;
  StreamSubscription<Position> positionStream;
  Data data;
  var _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> multiImei = new List<String>();
  List<Imei> multiImeis = new List<Imei>();
  Permission permission;
  SpeechRecognition _speechRecognition;
  var descriptionController = new TextEditingController(), sinisterController = new TextEditingController(), townController = new TextEditingController();
  int mins = 0, counter = 0;
  final SpeechToText speech = SpeechToText();
  double minSoundLevel = 50000, maxSoundLevel = -50000, level = 0.0;
  AnimationController _controller;
  int levelClock = 180;
  Dio dio = new Dio();



  var _villes = [
    'YAOUNDE',
    'DOUALA',
    'BAMENDA',
    'MAROUA',
    'EBOLOWA',
    'LIMBE',
    'GAROUA',
    'NGAOUNDERE',
    'KRIBI',
    'BERTOUA',
    'BAFOUSSAM',
    'DSCHANG',
    'BUEA',
    'AUTRE'
  ];

  var _sinistres = [
    'Incident 0',
    'Incident 1',
    'Incident 2',
    'Incident 3',
    'Incident 4',
    'Incident 5',
    'Incident 6',
    'Incident 7',
    'Incident 8',
    'Incident 9',
    'Autre'
  ];

  @override
  void initState(){
    super.initState();
    getPermission();
    getImei();
    initSpeechState();

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
    );
    //image1 = "http://192.168.100.10:9098/api/oculus/files/image_picker8691808718786603495.jpg";
  }

  @override
  void dispose(){
    positionStream.cancel();
    descriptionController.dispose();
    sinisterController.dispose();
    townController.dispose();
    super.dispose();
  }

  void checkConnection(var body, int q) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if(q == 0){
        setState(() {
          isLoading = true;
        });
        this.createOculus();
      }else if(q == 1){
        setState(() {
          galeryLoading = true;
        });
        this.getImage(0);//Galery
      }else if(q == 2){
        setState(() {
          cameraLoading = true;
        });
        this.getImage(1);//Camera
      }

    } else if (connectivityResult == ConnectivityResult.wifi) {
      if(q == 0){
        setState(() {
          isLoading = true;
        });
        this.createOculus();
      }else if(q == 1){
        setState(() {
          galeryLoading = true;
        });
        this.getImage(0);//Galery
      }else if(q == 2){
        setState(() {
          cameraLoading = true;
        });
        this.getImage(1);//Camera
      }
    } else {
      ackAlert(context, -1, null);
    }
  }

  Future<String> createOculus() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await client.postUrl(Uri.parse("$BaseUrl/create"));
    request.headers.set('accept', 'application/json');
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(jsonEncode(data)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print("statusCode ${response.statusCode}");
    print("body $reply");
    if (response.statusCode < 200 || json == null) {
      setState(() {
        isLoading =false;
      });
      throw new Exception("Error while fetching data");
    }else if(response.statusCode == 200){
      var responseJson = json.decode(reply);
      print(responseJson);
      setState(() {
        isLoading =false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (_) => Recap()));
    }else {
      setState(() {
        isLoading =false;
      });
      showInSnackBar("Service indisponible!", scaffoldKey);
    }
    return null;
  }

  getPermission() async {
    await Permission.microphone.request();
    await Permission.location.request();
    listGeolocalization();
    await Permission.speech.request();
    await Permission.camera.request();
    await Permission.accessMediaLocation.request();
  }

  initSpeechRecognizer(){
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler((result) {
      setState(() {
        _isAvailable = result;
      });
    });

    _speechRecognition.setRecognitionStartedHandler(() {
      setState(() {
        _isListening = true;
      });
    });

    _speechRecognition.setRecognitionResultHandler((speech) {
      setState(() {
        resultText = speech;
        descriptionController.text = speech;
      });
    });

    _speechRecognition.setRecognitionCompleteHandler(() {
      setState(() {
        _isListening = false;
      });
    });

    _speechRecognition.activate().then((value){
      setState(() {
        _isAvailable = false;
      });
    });
    print("Les différents booleens: $_isListening    $_isAvailable");
  }


  getImei() async {
    imei = await ImeiPlugin.getImei();
    multiImei = await ImeiPlugin.getImeiMulti();
    print("Les imei sont:");
    for(int i=0; i<multiImei.length; i++){
      Imei imei = new Imei(
        imei: this.multiImei[i]
      );
      multiImeis.add(imei);
    }
  }

  Future<String> getImage(int q) async {
    File image;
    if(q == 1){
      final pickedFile = await picker.getImage(source: ImageSource.gallery); //image1
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image selected from gallery');
        }
        galeryLoading = true;
      });
    }else if(q == 2){
      final pickedFile = await picker.getImage(source: ImageSource.gallery); // image2
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image taken from camera.');
        }
        cameraLoading = true;
      });
    }else if(q == 3){
      final pickedFile = await picker.getImage(source: ImageSource.camera); //image1
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image selected from gallery');
        }
        galeryLoading = true;
      });
    }else if(q == 4){
      final pickedFile = await picker.getImage(source: ImageSource.camera); // image2
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image taken from camera.');
        }
        cameraLoading = true;
      });
    }
    print("%%%%%%%%%%%%%%%%%%%%%%%%%% $image");
    if(image == null){
      setState(() {
        galeryLoading = false;
        cameraLoading = false;
      });
    }else
      Upload(image, q);
    return null;
  }

  Upload(File image, int q) async{
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    Response response;
    try{
      String filename = image.path.split('/').last;
      var formData = new FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: filename, contentType: MediaType('image', 'jpg')),
      });
      response = await dio.post("$BaseUrl",data: formData, options: Options(
        contentType: ContentType.json.toString(),
        responseType: ResponseType.json,
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        },
      ));
      print("L'url: $BaseUrl");
      print("Le statusCode: ${response.statusCode}");
      if(response.statusCode == 200){
        print("Voici l'image: ${response.data} et q ==== $q");
        if(q == 1 || q == 3){
          setState(() {
            image1 = "${response.data}";
            galeryLoading = false;
          });
        }else if(q == 2 || q == 4){
          setState(() {
            image2 = "${response.data}";
            cameraLoading = false;
          });
        }
        showInSnackBar("Téléchargement de l'image réussi avec succès.", scaffoldKey);
      }else{
        if(q == 1 || q == 2 || q == 3 || q == 4){
          setState(() {
            galeryLoading = false;
            cameraLoading = false;
          });
        }
        print("Le status est: ${response.statusCode}");
        showInSnackBar("Service indisponible, réessayez plus tard!", scaffoldKey);
      }
    }catch(e){
      print("l'erreur dio: $e");
      if(q == 1 || q == 2 || q == 3 || q == 4){
        setState(() {
          galeryLoading = false;
          cameraLoading = false;
        });
      }
      showInSnackBar("Service indisponible, réessayez plus tard!", scaffoldKey);
    }
  }


  Widget _buildTown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ville',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        ville == 'AUTRE'  || isTown == true?Container():Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          child: Row(
            children: <Widget>[
              new Expanded(
                flex:2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: new Icon(Icons.location_on, color: BLANC,),
                ),
              ),
              Expanded(
                flex: 12,
                child: DropdownButtonHideUnderline(
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: Color(0xFF73AEF5),),
                      child:  DropdownButton<String>(
                        icon: Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: new Icon(Icons.arrow_drop_down,
                            color: BLANC,),
                        ),
                        isDense: false,
                        elevation: 1,
                        isExpanded: true,
                        onChanged: (String selected){
                          setState(() {
                            ville = selected;
                          });
                        },
                        value: ville,
                        hint:Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Ville',
                            style: kHintTextStyle,
                            ),
                        ),
                        items: _villes.map((String name){
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                ),),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
        ville == 'AUTRE' || isTown == true?Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          //height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              controller: townController,
              maxLines: null,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              onChanged: (value){
                if(value.isEmpty){
                  setState(() {
                    isTown = false;
                  });
                }else{
                  setState(() {
                    isTown = true;
                  });
                }
              },
              validator: (value){
                if(value.isNotEmpty){
                  ville = value;
                  townController.text = ville;
                }
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ville',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ):Container(),

        ville == null || (isTown == false && ville == 'AUTRE')?
        Text("Ville obligatoire*", style: TextStyle(
            color: Colors.red,
            fontSize: Ttext - 1
        ),):
        Container()
      ],
    );
  }

  Widget _buildSinister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Incident',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        sinistre == 'Autre' || isSinister == true?Container():Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          child: Row(
            children: <Widget>[
              new Expanded(
                flex:2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: new Icon(Icons.airline_seat_individual_suite, color: BLANC,),
                ),
              ),
              Expanded(
                flex: 12,
                child: DropdownButtonHideUnderline(
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: Color(0xFF73AEF5),),
                      child: DropdownButton<String>(
                        icon: Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: new Icon(Icons.arrow_drop_down,
                            color: BLANC,),
                        ),
                        isDense: false,
                        elevation: 1,
                        isExpanded: true,
                        onChanged: (String selected){
                          setState(() {
                            sinistre = selected;
                          });
                        },
                        value: sinistre,
                        hint:Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Incident à déclarer',
                            style: kHintTextStyle,
                          ),
                        ),
                        items: _sinistres.map((String name){
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                ),),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
        sinistre == 'Autre' || isSinister == true?Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          //height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              controller: sinisterController,
              maxLines: null,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              onChanged: (value){
                if(value.isEmpty){
                  setState(() {
                    isSinister = false;
                  });
                }else{
                  setState(() {
                    isSinister = true;
                  });
                }
              },
              validator: (value){
                if(value.isNotEmpty){
                  sinistre = value;
                  sinisterController.text = sinistre;
                }
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Incident',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ):Container(),
        sinistre == null || (isSinister == false && sinistre == 'Autre')?
        Text("Incident obligatoire*", style: TextStyle(
            color: Colors.red,
            fontSize: Ttext - 1
        ),):
        Container()
      ],
    );
  }

  Widget _buildDescription() {
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
              controller: descriptionController,
              maxLines: null,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              onChanged: (value){
                if(value.isEmpty){
                  setState(() {
                    isdescrip = false;
                  });
                }else{
                  setState(() {
                    isdescrip = true;
                  });
                }
              },
              validator: (value){
                if(value.isNotEmpty){
                  description = value;
                }
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Description',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),

        isdescrip == false?
        Text("Description obligatoire*", style: TextStyle(
            color: Colors.red,
            fontSize: Ttext - 1
        ),):
        Container()
      ],
    );
  }

  Widget _buildPhone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Téléphone',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          //alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: Hchamp,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              onChanged: (value){
                if(value.isNotEmpty){
                  setState(() {
                    isPhone = true;
                  });
                }else{
                  setState(() {
                    isPhone = false;
                  });
                }
              },
              validator: (value){
                if(value.isEmpty){
                  setState(() {
                    isPhone = false;
                  });
                }else{
                  contact = value;
                }
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Téléphone',
                hintStyle: kHintTextStyle,
                icon: Icon(Icons.phone, color: BLANC,),
              ),
            ),
          ),
        ),
        isPhone == false && callMe == true?
            Text("Numéro de téléphone obligatoire*", style: TextStyle(
              color: Colors.red,
              fontSize: Ttext - 1
            ),):
            Container()
      ],
    );
  }

  Widget _buildCallMe() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: callMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  callMe = value;
                  isPhone = false;
                });
              },
            ),
          ),
          Text(
            'Me rappeler',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildPicture(int q){
    return InkWell(
      onTap: (){
        if(q == 1){
          ackAlert(context, 1, getImage);
        }else if(q == 2){
          ackAlert(context, 2, getImage);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (q == 1 && galeryLoading == true) || (q == 2 && cameraLoading == true)?Center(child: CupertinoActivityIndicator(radius: 20,)): Text(
            q == 1 || q == 3?'Pièce N°1':'Pièce N°2',
            style: kLabelStyle,
          ),
          SizedBox(height: 10.0),
          Image.network(q == 1 || q == 3?image1:image2,
              loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent loadingProgress){
                if (loadingProgress == null)
                  return Image.network(q == 1 || q == 3?image1:image2,);
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null ?
                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              }
          ),
      /*Center(child: CupertinoActivityIndicator(radius: 20,)),
          Center(
            child: FadeInImage.memoryNetwork(
              placeholder: list,
              image: q == 1 || q == 3?image1:image2,
            ),
          ),
         Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    image: NetworkImage(q == 1 || q == 3?image1:image2),
                    fit: BoxFit.cover
                )
            ),
            alignment: Alignment.centerLeft,
            child: Image.network(q == 1 || q == 3?image1:image2, fit: BoxFit.contain,
                loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent loadingProgress){
                  if (loadingProgress == null) return Container();
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null ?
                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                }
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildDefaultPicture(int q){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          q == 1 || q == 3?'Pièce N°1':'pièce N°2',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          height: MediaQuery.of(context).size.width - 40,
          alignment: Alignment.center,
          decoration: kBoxDecorationStyle,
          child: (galeryLoading == true && (q == 1 || q == 3)) || (cameraLoading == true && (q == 2|| q == 4))?CupertinoActivityIndicator(radius: 20,): IconButton(
            onPressed: (){
              if(q == 1){
                ackAlert(context, 1, getImage);
              }else if(q == 2){
                ackAlert(context, 2, getImage);
              }
            },
            iconSize: MediaQuery.of(context).size.width/2,
            icon: Icon(Icons.image),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 30.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        _buildTown(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildSinister(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildDescription(),

                        SizedBox(
                          height: 20.0,
                        ),
                        image1 == null?_buildDefaultPicture(1):_buildPicture(1),
                        SizedBox(
                          height: 20.0,
                        ),
                        image2 == null?_buildDefaultPicture(2):_buildPicture(2),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildCallMe(),
                        callMe == false?Container():SizedBox(
                          height: 20.0,
                        ),
                        callMe == false?Container():_buildPhone(),
                        SizedBox(
                          height: 10.0,
                        ),
                    InkWell(
                      onTap: (){
                        if(_formKey.currentState.validate()){
                          if(isPhone == true && callMe == true || callMe == false){
                            created_at = "${DateTime.now().day}/"+"${DateTime.now().month}/"+"${DateTime.now().year} - ${DateTime.now().hour}h : "+"${DateTime.now().minute}min : "+"${DateTime.now().second}sec";
                            print("created_at $created_at");
                            data = new Data(
                                phone: contact,
                                latitude: latitude,
                                longitude: longitude,
                                ville: ville,
                                incident: sinistre,
                                description: description,
                                voice: voice,
                                created_at: created_at,
                                imei: imei,
                                multiImei: multiImeis,
                                image1: image1,
                                image2: image2,
                                callMe: callMe
                            );
                            print("L'objet "+json.encode(data));
                            checkConnection(json.encode(data), 0);
                          }else{

                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Container(
                          height: Hchamp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: BLANC,
                          ),
                          child: Center(
                            child: isLoading == false?Text("VALIDER", style: TextStyle(color: Color(0xFF527DAA), fontWeight: FontWeight.bold, fontFamily: 'OpenSans'),):
                            CupertinoActivityIndicator(),
                          ),
                        ),
                      ),
                    )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      /*floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          status == "listening"?FloatingActionButton(
            onPressed: (){

            },
            backgroundColor: BLANC,
            child: Countdown(
              animation: StepTween(
                begin: levelClock, // THIS IS A USER ENTERED NUMBER
                end: 0,
              ).animate(_controller),
            )
          ):Container(),

          SizedBox(height: 10,),

          FloatingActionButton(
            onPressed: (){
              print("La valeur de _hasSpeech: $_hasSpeech");
              !_hasSpeech || speech.isListening? null: startListening();
            },

            backgroundColor: Colors.red,
            child: Icon(Icons.mic_none, color: BLANC,),
          ),
        ],
      )*/
    );
  }

  /*geolocalization() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(currentPosition.toString());
    lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition.toString());
  }*/

  listGeolocalization(){
    positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10).listen((Position position) {
      print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });
    });
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener
    );
    if(!mounted) return;
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }
  getTime(){
    if(!isRecording){
      if(counter>0){
        setState(() {
          mins = counter;
        });
      }
      counter = 0;
    }else
      while(isRecording){
        counter ++;
      }
  }

  Future<void> statusListener(String status) async {
    setState(() {
      this.status = status;
    });
    if(this.status == "listening"){
      _controller.forward();
    }else{
      _controller.reset();
    }
    print("La valeur du status est: $status");
  }

  void errorListener(SpeechRecognitionError errorNotification){
    _controller.reset();
    print("La valeur sur l'erreur: $errorNotification");
  }

  startListening() {
    speech.listen(
      onResult: resultListening,
      listenFor: Duration(seconds: 10),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      partialResults: true,
      onDevice: true,
      listenMode: ListenMode.confirmation
    );
  }

  void resultListening(SpeechRecognitionResult result){
    if(result.finalResult){
      setState(() {
        outputText = result.recognizedWords;
        descriptionController.text = outputText;
      });
    }
  }

  soundLevelListener(double level){
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }
}


class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    print('animation.value  ${animation.value} ');
    print('inMinutes ${clockTimer.inMinutes.toString()}');
    print('inSeconds ${clockTimer.inSeconds.toString()}');
    print('inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: Ttext,
        color: Color(0xFF73AEF5),
      ),
    );
  }
}