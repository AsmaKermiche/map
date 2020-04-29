import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:battery/battery.dart';
class DeviceInfoService {
  final  DatabaseReference _infoConnected = FirebaseDatabase.instance.reference().child('.info/connected');
  final DatabaseReference _userStatus = FirebaseDatabase.instance.reference().child('status');
  final Battery _battery = Battery ();
  //TODO bool getBatteryLevel ;

  DeviceInfoService(bool getBatteryLevel){
    //this.getBatteryLevel = getBatteryLevel;
  }
  Future<int> batteryLevel  () async {
    return await  _battery.batteryLevel ;
  }

  void listenToChangeStatus (String uid){
    _infoConnected.onValue.listen((event){
      bool status = event.snapshot.value ;
      if(status){
        _userStatus.child(uid).onDisconnect().set({
          'online' : false ,
          'LastSeen' : ServerValue.timestamp ,
        });
        _userStatus.child(uid).set({
          'online' : true ,
        });
      }
    });
  }
}

