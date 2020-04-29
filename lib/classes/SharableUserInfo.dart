import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:maps/classes/transport.dart';

class SharableUserInfo implements Comparable<SharableUserInfo>{
  String _id;
  String _username; //Never changes
  String _displayName;
  GeoPoint _location;
  double _vitesse;
  bool _active;
  bool _photo ;
  Gender _gender ;
  DateTime _dateOfBirth ;
  String _photoPath ;
  bool _online ;
  //Optional
  Vehicle _vehicule;
  String _phone;
  Transport _transport;
  int _batteryLevel ;



  SharableUserInfo (String id,String username,String displayName,Gender gender , DateTime dateOfBirth ){
    _id = id;
    _username = username;
    _active = true;
    _displayName = displayName;
    _photo = false ;
    _gender = gender ;
    _dateOfBirth = dateOfBirth;
    _photoPath = 'users'+_username + '/' + 'profilePhoto' ;
    _online = true ;
  }
  SharableUserInfo.fromMap (String id,Map<String,dynamic> userData){
    _id = id;
    _username = userData['Username'];
    _photo = userData['Username'];
    _displayName = userData['Displayname'];
    _active = userData['Active'];
    _location = userData['Position'];
    _vitesse = userData['Vitesse'];
    _dateOfBirth = userData['DateOfBirth'];
    _batteryLevel = userData['BatteryLevel'];
    _gender = EnumToString.fromString(Gender.values,userData['Gender']);
    _photoPath = 'users'+_username + '/' + 'profilePhoto' ;
    _online = true;
    if(userData.containsKey('BatteryLevel'))
      _batteryLevel = userData['BatteryLevel'];
    if(userData.containsKey('Phone')){
      _phone = userData['Phone'];
    }
    if(userData.containsKey('Transport')){
      _transport = userData['Transport'];
    }
    if(userData.containsKey('Vehicule')){
      _vehicule = Vehicle.fromMap(userData['Vehicule']);
    }
  }
  Map<String,dynamic> sharableUserInfoToMap () => {
    'UID' : _id,
    'Displayname' : _displayName ,
    'Username' : _username,
    'Photo' : _photo,
    'Active' : true ,
    'Gender' : _gender.toString(),
    'DateOfBirth' : Timestamp.fromDate(_dateOfBirth),
    'Online' : true,
  };


  void display (){
    print('ID  : $_id');
    print('Username : $_username');
    print('Displayname : $_displayName');
    print('DateOfBirth :$_dateOfBirth');
    print('Location : $_location');
    print('Speed : $_vitesse');
    //print('Username : $_username');
    print('Phone : $_phone');
    print('Transport : $_transport');
    print('Battery :$_batteryLevel');
    print('Online :$_online');
  }

  String get id => _id;

  Vehicle get vehicule => _vehicule; //Getters

  Transport get transport => _transport;

  double get vitesse => _vitesse;

  String get username => _username;

  String get displayName => _displayName;

  String get phone => _phone;

  GeoPoint get location => _location;

  DateTime get dateOfBirth => _dateOfBirth;

  bool get active => _active;

  bool get photo => _photo;

  bool get online => _online;

  Gender get gender => _gender;

  String get photoPath => _photoPath;

 int get batteryLevel => _batteryLevel ;
  //Setters
  set online(bool value) {
    _online = value;
  }
  set active(bool value) {
    _active = value;
  }

  set location(GeoPoint value) {
    _location = value;
  }


  set vitesse(double value) {
    _vitesse = value;
  }


  set displayName(String value) {
    _displayName = value;
  }

  set transport(Transport value) {
    _transport = value;
  }

  set vehicule(Vehicle value) {
    _vehicule = value;
  }

  set phone(String value) {
    _phone = value;
  }


  set photo(bool value) {
    _photo = value;
  }

  set batteryLevel(int value) {
    _batteryLevel = value;
  }


  void setInfoGroup (Map<String,dynamic> userData){
    _location = userData['Position'];
    _vitesse = userData['Vitesse'];
    _batteryLevel = userData['BatteryLevel'];
    if(userData.containsKey('Phone')){
      _phone = userData['Phone'];
      _transport = userData['Transport'];
    }
    if(userData.containsKey('Transport')){
      _transport = userData['Transport'];
    }
    if(userData.containsKey('Vehicule')){
      _vehicule = userData['Vehicule'];
    }
  }
  void setInfoPublic (Map<String,dynamic> userData){
    _displayName = userData['Displayname'];
    _photo = userData['Photo'];
  }
  @override
  int compareTo (SharableUserInfo sharableUserInfo){
    return  this.dateOfBirth.compareTo(sharableUserInfo.dateOfBirth);
  }
}
enum Gender {
  Male,Female
}