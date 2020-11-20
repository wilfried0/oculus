import 'package:flutter/material.dart';

final Color VERT_FONCE = Color(0xFF204749);
final Color VERT = Color(0xFF408389);
final Color VERT_CLAIR = Color(0xFF69B9BC);
final Color VERT_BLANC = Color(0xFFD6EDEE);
final Color GRISE = Color(0xFFF2F2F2);
final Color GRIS = Color(0xFFE0E0E0);
final Color GRAY = Color(0xFF606060);
final Color NOIR = Color(0xFF000000);
final Color BLANC = Color(0xFFFFFFFF);


/*
*
*
* String ville, sinistre, description;

  var _villes = [
    'YAOUNDE',
    'DOUALA',
    'BAMENDA',
    'MAROUA',
    'EBOLOWA',
    'MAROUA',
    'GAROUA',
    'NGAOUNDERE',
    'KRIBI',
    'BERTOUA',
    'BAFOUSSAM',
    'DSCHANG',
    'BUEA'
  ];

  var _sinistres = [
    'Sinistre 0',
    'Sinistre 1',
    'Sinistre 2',
    'Sinistre 3',
    'Sinistre 4',
    'Sinistre 5',
    'Sinistre 6',
    'Sinistre 7',
    'Sinistre 8',
    'Sinistre 9'
  ];
      extendBodyBehindAppBar: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover
            )
        ),
        child: BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: .5, sigmaY: .5),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
                    child: Container(
                      decoration: new BoxDecoration(
                        color: GRIS,
                        borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(10.0),
                        ),
                        border: Border.all(
                            color: BLANC,
                            width: bordure
                        ),
                      ),
                      height: Hchamp,
                      child: Row(
                        children: <Widget>[
                          new Expanded(
                            flex:2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: new Icon(Icons.location_on, color: VERT_CLAIR,),
                            ),
                          ),
                          Expanded(
                            flex: 12,
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  icon: new Icon(Icons.arrow_drop_down,
                                    color: VERT_CLAIR,),
                                  isDense: false,
                                  elevation: 1,
                                  isExpanded: true,
                                  onChanged: (String selected){
                                    setState(() {
                                      ville = selected;
                                    });
                                  },
                                  value: ville,
                                  hint:Text('Ville',
                                    style: TextStyle(
                                      color: GRAY,
                                      fontSize:Ttext,
                                    ),),
                                  items: _villes.map((String name){
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(name,
                                          style: TextStyle(
                                            color: NOIR,
                                            fontSize:Ttext,
                                          ),),
                                      ),
                                    );
                                  }).toList(),
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
                    child: Container(
                      decoration: new BoxDecoration(
                        color: GRIS,
                        borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(10.0),
                        ),
                        border: Border.all(
                            color: BLANC,
                            width: bordure
                        ),
                      ),
                      height: Hchamp,
                      child: Row(
                        children: <Widget>[
                          new Expanded(
                            flex:2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: new Icon(Icons.airline_seat_individual_suite, color: VERT_CLAIR,),
                            ),
                          ),
                          Expanded(
                            flex: 12,
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  icon: new Icon(Icons.arrow_drop_down,
                                    color: VERT_CLAIR,),
                                  isDense: false,
                                  elevation: 1,
                                  isExpanded: true,
                                  onChanged: (String selected){
                                    setState(() {
                                      sinistre = selected;
                                    });
                                  },
                                  value: sinistre,
                                  hint:Text('Sinistre à déclarer',
                                    style: TextStyle(
                                      color: GRAY,
                                      fontSize:Ttext,
                                    ),),
                                  items: _sinistres.map((String name){
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(name,
                                          style: TextStyle(
                                            color: NOIR,
                                            fontSize:Ttext,
                                          ),),
                                      ),
                                    );
                                  }).toList(),
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 40, right: 40),
                    child: Container(
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(0.0),
                        ),
                        color: GRIS,
                        border: Border.all(
                            color: Colors.transparent,
                            width: 0
                        ),
                      ),
                      height: Hchamp,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: TextFormField(
                          cursorColor: NOIR,
                            maxLines: null,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: VERT),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(0.0),
                                    topRight: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(0.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: VERT),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(0.0),
                                    topRight: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(0.0),
                                  ),
                                ),
                                labelText: "Description du sinistre",labelStyle: new TextStyle(
                                color: NOIR,
                                fontSize: Ttext,
                                fontWeight: FontWeight.normal)
                            ),
                            validator: (value) {
                              if (value.isEmpty)
                                return "Description vide!";
                              else{
                                setState(() {
                                  description = value;
                                });
                                return null;
                              }
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

* */