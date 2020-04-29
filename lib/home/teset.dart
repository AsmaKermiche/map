/*import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';


class MapsDemo extends StatefulWidget {
  MapsDemo() : super();
  final String title = "Map project";

  @override
  MapsDemoState createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  //
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  final Set <Marker> _markers = {} ; // hadi une liste ntaa les markers li fel map
  LatLng _lastMapPosition = _center;  // hadi initialisation  ki tfteh l app win ji l map
  MapType _currentMapType = MapType.normal;
  GoogleMapController mapController ;
  double zoomVal=11.0;  // hadi chhal ykon zoom fel map
  String searchADR ; // l adr li ydekhelha l'utilisateur

  /****  hadoo nta la route mezel mkmlhach mahich tmchi ***************/
  List <LatLng> routeCoords ; // hadi bch nkhdem  la route route
  final Set <Polyline> polyline = {} ;// liste nta les route li ykono fel map
  GoogleMapPolyline googleMapPolyline =new GoogleMapPolyline(apiKey:"AIzaSyDwUVeRFcx46wRgf4cPQ-lw37EyFaGlc_A");
  getsomePoints() async {
    var currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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

  chercher()
  {
    Geolocator().placemarkFromAddress(searchADR).then((result) {  mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition ( target: LatLng (result[0].position.latitude, result[0].position.longitude), zoom: 11.0 ,  ),
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
    _lastMapPosition = position.target; // kima kotlk l fo9 hna lmap tah tban fhadok l ihdathiat li medithomlha
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
        CameraPosition ( target: LatLng (currentLocation.latitude, currentLocation.longitude), zoom: 11.0 ,  ),
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

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }
  /****zooom in and Zoom out ****/
  Future<void> _minus(double zoomVal) async {

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition( target : LatLng(_lastMapPosition.latitude,_lastMapPosition.longitude) , zoom: zoomVal)));
  }
  Future<void> _plus(double zoomVal) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition( target: LatLng(_lastMapPosition.latitude, _lastMapPosition.longitude)  , zoom: zoomVal)));
  }
  zoomplus() {     print(zoomVal) ; zoomVal++ ;_plus(zoomVal) ; }
  zoommoin(){zoomVal-- ; _minus(zoomVal) ;}
//**************************************************************//
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              /* hadi widjet ntaa l map o hadi hia li tbeyenena l map fe application ntaena o  hada kamel bel khetrch andna controlleur googlmapcontroler */
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

            Positioned(top: 30.0, right: 15.0, left: 15.0,
                child: Container(height: 50.0, width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                  child: TextField(decoration: InputDecoration(hintText: 'enter adress', border: InputBorder.none,suffixIcon: IconButton( icon: Icon(Icons.search),
                    onPressed: chercher , iconSize: 30.0,
                  ),
                  ),
                    onChanged: (val) {
                      setState(() {
                        searchADR = val ;
                      });
                    },
                  ),
                )
            ),
            Positioned ( top: 80,
              child: Padding(
                padding: EdgeInsets.all(16.0),

                child: Column(

                  children: <Widget>[
                    button(_onMapTypeButtonPressed, Icons.map),
                    button (_onAddMarkerButtonPressed(),Icons.add_location) ,
                    button(_segeolocaliser , Icons.arrow_drop_down_circle) ,

                    button ( zoomplus , Icons.add) ,
                    button(zoommoin, Icons.remove ) ,
                  ],

                ),

              ),
            ),
          ],

        ),
      ),
    );
  }
}
*/
