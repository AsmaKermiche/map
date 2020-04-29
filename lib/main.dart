import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:maps/select_group.dart';
import 'package:permission/permission.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';


void main () => runApp(MyApp());
class MyApp extends StatefulWidget {
  MyApp(): super();
  final String title = "Map project";

  @override
  MapsDemoState createState() => MapsDemoState();
}

class MapsDemoState extends State<MyApp> {
  //
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  final Set <Marker> _markers = {
  }; // hadi une liste ntaa les markers li fel map
  LatLng _lastMapPosition = _center; // hadi initialisation  ki tfteh l app win ji l map
  MapType _currentMapType = MapType.normal;
  GoogleMapController mapController;

  double zoomVal = 11.0; // hadi chhal ykon zoom fel map
  String searchADR; // l adr li ydekhelha l'utilisateur

  /****  hadoo nta la route mezel mkmlhach mahich tmchi ***************/
  List <LatLng> routeCoords; // hadi bch nkhdem  la route route
  final Set <Polyline> polyline = {}; // liste nta les route li ykono fel map
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(
      apiKey: "AIzaSyDwUVeRFcx46wRgf4cPQ-lw37EyFaGlc_A");

  getsomePoints() async {
    var currentLocation = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(currentLocation.latitude, currentLocation.longitude),
        destination: LatLng(36.373749, 3.902800),
        mode: RouteMode.driving);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getsomePoints();
  }

  /***********                                               **********************************/

  chercher() {
    Geolocator().placemarkFromAddress(searchADR).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(
            result[0].position.latitude, result[0].position.longitude),
          zoom: 11.0,),
      ),
      );
    });
  }

  /*** hadoo les module bach  ntaa lmap bach nkherejha *********/

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: routeCoords,
          width: 4,
          color: Colors.black,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position
        .target; // kima kotlk l fo9 hna lmap tah tban fhadok l ihdathiat li medithomlha
  }

/*************************************************************/
  /*module ntaa  map type      */
  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

/* hada nta3 la localisation */
  _segeolocaliser() async {
    /*  hadi tmedlk l ihdathiat win raky */
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    /* hna bach ndir une marque f ma position */
    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers.add(marker);
      /* hna bach tsra hadik l'animation ida konti fi plassa khra la map trej3ek f ta position */
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 11.0,),
      ),
      );
    });
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'marker',
          snippet: 'place',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  Widget button(Function function, IconData icon, Color color1 , Color color2) {
    return Container(
        height: 45,
        width: 45,
        child: FittedBox(
          child:
          FloatingActionButton(
            onPressed: function,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: color1,
            child: Icon(
              icon,
              size: 30.0,
              color:color2
            ),
          ),
        )
    );
  }

  /****zooom in and Zoom out ****/
  Future<void> _minus(double zoomVal) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_lastMapPosition.latitude, _lastMapPosition.longitude),
        zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_lastMapPosition.latitude, _lastMapPosition.longitude),
        zoom: zoomVal)));
  }

  zoomplus() {
    print(zoomVal);
    zoomVal++;
    _plus(zoomVal);
  }

  zoommoin() {
    zoomVal--;
    _minus(zoomVal);
  }

//**************************************************************//
  String _lastSelected = 'TAB: 0';

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

  AnimationController animationController;
  Animation degOneTranslationAnimation, degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation rotationAnimation;



  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  int currentIndex = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 50.0,
          items: <Widget>[
            Icon(Icons.map, size: 30,color:Colors.orangeAccent),
            Icon(Icons.history, size: 30,color:Colors.orangeAccent),
            Icon(Icons.add, size: 30,color:Colors.orangeAccent),
            Icon(Icons.security, size: 30,color:Colors.orangeAccent),
            Icon(Icons.settings, size:30 ,color:Colors.orangeAccent),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.orangeAccent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
            });
          },
        ),

        //backgroundColor: const Color(0xFFEFEFEF),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[

            GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                 mapType: _currentMapType,
                 markers: _markers,
                 polylines: polyline,
                onCameraMove: _onCameraMove,
              ),
            Positioned(
              top:40,
              right:5,
              child:button(zoommoin, Icons.chat, Colors.white,Colors.orangeAccent),
            ),
            Positioned(
              top:40,
              left:5,
              child:button(zoommoin, Icons.search, Colors.white,Colors.orangeAccent),
            ),
            Mygroup(),


            Positioned(
              right: 10,
              bottom: 220,
              child: Column(
                  children: <Widget>[
                    //Amina there is the buttons
                    //1************************************
                    // the button of auto-tracking
                    button(zoommoin, Icons.my_location, Colors.white,Colors.orangeAccent),
                    button(zoommoin, Icons.filter_none, Colors.white,Colors.orangeAccent),

                    //  button(zoomplus, Icons.zoom_in, Colors.orangeAccent),
                    //  button(_onMapTypeButtonPressed, Icons.map, Colors.orangeAccent)
                  ]),
            ),






          ],),
      ),
    );
  }
  Future<void> _alertExample(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert example'),
          content: new Container(child: new Text(message)),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


