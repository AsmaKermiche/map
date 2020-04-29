/*import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';
import 'package:ourwonderfullapp/home/fab_bottom/fab_with_icons.dart';
import 'package:ourwonderfullapp/home/fab_bottom/fab_bottom_app_bar.dart';
import 'package:ourwonderfullapp/home/fab_bottom/layout.dart';

class MapsDemo extends StatefulWidget {
  MapsDemo() : super();
  final String title = "Map project";

  @override
  MapsDemoState createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo>{
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
//***********                                               **********************************/

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

  Widget button(Function function, IconData icon , Color color) {
    return Container(
      height: 45,
      width: 45,
      child: FittedBox(
        child:
        FloatingActionButton(
          onPressed: function,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: color,
          child: Icon(
            icon,
            size: 30.0,
          ),
        ),
      )
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
  Animation degOneTranslationAnimation,degTwoTranslationAnimation,degThreeTranslationAnimation;
  Animation rotationAnimation;


  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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

            Positioned(top: 40.0, right: 15.0, left: 15.0,
                child: Container(height: 50.0, width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0), color: Colors.white54),
                  child: TextField(decoration: InputDecoration(hintText: 'Entrer l\'adresse ici', border: InputBorder.none,prefixIcon: IconButton( icon: Icon(Icons.search), color: Colors.orangeAccent,
                    onPressed: chercher , iconSize: 25.0,
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
            Positioned(
                right: 20,
                bottom: 70,
                child: Column(
                  children: <Widget>[
                    //Amina there is the buttons
                    //1************************************
                    // the button of auto-tracking
                    button(zoommoin, Icons.zoom_out , Colors.orangeAccent),
                    button(zoomplus, Icons.zoom_in,Colors.orangeAccent ),
                    button(_onMapTypeButtonPressed, Icons.map,Colors.orangeAccent )
                  ]),
                    ),
          ],),

        bottomNavigationBar: FABBottomAppBar(
          centerItemText: 'Add',
          color: Colors.grey,
          selectedColor: Colors.orangeAccent,
          notchedShape: CircularNotchedRectangle(),
          onTabSelected: _selectedTab,
          items: [
            FABBottomAppBarItem(iconData: Icons.location_on, text: 'Location'),
            FABBottomAppBarItem(iconData: Icons.group, text: 'Group'),
            FABBottomAppBarItem(iconData: Icons.message, text: 'Message'),
            FABBottomAppBarItem(iconData: Icons.settings, text: 'Settings'),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFab(
            context),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final icons = [ Icons.person_add, Icons.add_alert, Icons.add_comment];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx , offset.dy - icons.length * 35.0),
          child: FabWithIcons(
            icons: icons,
          ),
        );
      },

      child: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }


}
class CircularButton extends StatelessWidget {

  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton({this.color, this.width, this.height, this.icon, this.onClick});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color,shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon,enableFeedback: true, onPressed: onClick),
    );
  }
}
*/
