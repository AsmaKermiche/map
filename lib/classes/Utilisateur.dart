import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:maps/classes/Groupe.dart';
import 'package:maps/classes/Request.dart';
import 'package:maps/classes/TimePlace.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maps/classes/Message.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/servises/DeviceInfoService.dart';
import 'package:maps/servises/firestore.dart';
import  'package:maps/classes/transport.dart';

class Utilisateur {
  //************************************* Attributs ***************************************************//
  SharableUserInfo _sharableUserInfo ;
  //Private info
  List<Vehicle>_listVehicles;
  List<TimePlace> _historique;
  Map<String, bool> _groupes;
  DeviceInfoService _deviceInfoService ;
  //Boite de reception
  List<Request> _invitations ;
  Map<TypeMessage,List<String>> _messagesPersonalisees ;

  //DB
  final Firestore _firestore = Firestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  DocumentReference _usersInfoDoc;


  //*****************************************Constructors*********************************************************//
  //Creer un nouveau utilisateur
  Utilisateur(String id,String displayName,String username,Gender gender,DateTime dateOfBirth) {
    //this._id = id;
    this._sharableUserInfo = SharableUserInfo(id,username, displayName,gender,dateOfBirth);
    //this._active = true;
    this._historique = new List<TimePlace>();
    this._groupes = new Map<String, bool>();
    this._listVehicles = new List<Vehicle>();
    this._invitations = new List<Request>();
    this._messagesPersonalisees = new Map<TypeMessage,List<String>> ();
    this._deviceInfoService = DeviceInfoService(false);
    this._usersInfoDoc = _firestore.collection('users').document(this.sharableUserInfo.id);
  }

  //Creer un utilisateur a partir d'un doc Firestore
  Utilisateur.old (String uid ,SharableUserInfo userInfo)
  {
    //this._id = uid ;
    this._usersInfoDoc = _firestore.collection('users').document(this.sharableUserInfo.id);
    this._sharableUserInfo = userInfo;
    this._groupes = new Map<String,bool> ();
    this._listVehicles = new List<Vehicle> ();
    //TODO this._deviceInfoService = DeviceInfoService(getBatteryLevel);
    //TODO boite de reception
    this._invitations = new List<Request>();
    this._historique = new List<TimePlace>();
  }

  //*********************************************Methods*****************************************************//
  //------------------------------------------Online status --------------------------------------------
  //Change display name
  void listenToChanges() async {
    //final DeviceInfoService deviceInfoService =
    DeviceInfoService(true).listenToChangeStatus(this._sharableUserInfo.id);
  }
  //------------------------------------------Display name--------------------------------------------
  //Change display name
  Future<void> setDisplayName(String newDisplayName) async {
    await _firestore.collection('usernames').document(this.sharableUserInfo.username).updateData({
      'DisplayName' : newDisplayName,
    }).then((_){
      this._sharableUserInfo.displayName = newDisplayName;
    });
  }
  //------------------------------------------Photo--------------------------------------------
  Future<void> setPhoto() async {
    File file;
    file = await FilePicker.getFile(type: FileType.image);
    await _uploadPhoto(file).then((_) async  {
      await _firestore.collection('usernames').document(this.sharableUserInfo.username).updateData({
        'Photo' : true ,
      }).then((_){
        _sharableUserInfo.photo = true;
        print('photo set');
      });
    }).catchError((error) {
      print('could\'nt set photo');
    });
  }

  Future<void> _uploadPhoto(File file) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(this._sharableUserInfo.photoPath);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print('photo url'+url);
  }

  Future<void> deletePhoto() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(this._sharableUserInfo.photoPath);
    storageReference.delete().whenComplete(() {
      _sharableUserInfo.photo = false;
      print('Profile photo deleted');
    }).catchError((error) {
      print('Could\'t delete profile photo');
    });
  }
  /*------------------------------------------Date of Birth--------------------------------------------
  void setDateOfBirth(DateTime dateOfBirth) async {
    await this._usersInfoDoc.updateData(
        {
          'DateOfBirth' : Timestamp.fromDate(dateOfBirth),
        }
    ).then((result) {
      this._sharableUserInfo.dateOfBirth=  dateOfBirth;
      print("phone number changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }
  //------------------------------------------Gender--------------------------------------------
  void setGender(Gender gender) async {
    await this._usersInfoDoc.updateData(
        {
          'Gender' : gender.toString(),
        }
    ).then((result) {
      this.sharableUserInfo.gender = gender;
      print("gender changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }*/

  //------------------------------------------Phone--------------------------------------------
  //TODO test
  void setPhone(String phone) async {
    await this._usersInfoDoc.updateData(
        {
          "Phone": phone,
        }
    ).then((result) {
      this._sharableUserInfo.phone =  phone;
      print("phone number changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  void removePhone() {
    this._usersInfoDoc.updateData(
        {
          "Phone": FieldValue.delete(),
        }
    ).then((result) {
      this._sharableUserInfo.phone = null;
      print("phone number removed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  //------------------------------------------ActiveStatus--------------------------------------------
  //Change active status
  void changeActiveStatus() {
    bool b = !_sharableUserInfo.active;
    this._usersInfoDoc.updateData(
        {
          "Active": b,
        }
    ).then((result) {
      _sharableUserInfo.active = b;
      print("Status changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  //---------------------------------------BatteryLevel------------------------------------------------
  void setBatteryLevel () async {
    while (true) {//_deviceInfoService.getBatteryLevel) {
      int bl = await _deviceInfoService.batteryLevel();
      this._usersInfoDoc.updateData({
        'BatteryLevel' : bl,
      }).then((_){
        _sharableUserInfo.batteryLevel = bl;
      });
      await Future.delayed(Duration(minutes: 1));
    }
  }

  void removeBatteryLevel () async {
    //_deviceInfoService.getBatteryLevel = false ;
    this._sharableUserInfo.batteryLevel = null;
    this._usersInfoDoc.updateData({
      'BatteryLevel' : FieldValue.delete(),
    });
  }

  //------------------------------------------Location--------------------------------------------
  //TODO Amina please zidi ta3 kitetbedal la position ttbedal la valeur ta3 _sharableUserInfo.location test :
  Future<void> setLocation() async {
    Geolocator geolocator = Geolocator(); //..forceAndroidLocationManager;
    Position location ;
    location = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((_) {
            this._sharableUserInfo.location = GeoPoint(location.latitude,location.longitude);
            print('we got cuurent position');
            this._usersInfoDoc.updateData(
            {
                'Position': _firestoreService.firestorePosition(location),
            }
      ).then((result) {
        print('position set');
      }).catchError((error) {
        print('Error : couldn\'t set position' + error.toString());
      });
    }).catchError((error) {
      print('Error : Couldn\'t get cuurent position' + error);
    });
  }

  //------------------------------------------Vitesse--------------------------------------------
  //TODO hna tan  :
  void setVitesse() async {
    Geolocator geolocator = Geolocator();
    Position location = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    double v = location.speed;
    this._usersInfoDoc.updateData(
        {
          'Vitesse': v,
        }
    ).then((result) {
      print('speed set');
      this._sharableUserInfo.vitesse = v;
    }).catchError((error) {
      print('Error : couldn\'t set speed' + error.toString());
    });
  }

  //------------------------------------------Transport --------------------------------------------
  void setTransport(Transport transport) {
    this._usersInfoDoc.updateData(
        {
          'Transport': transport.toString(),
        }
    ).then((result) {
      print('transport set');
      this._sharableUserInfo.transport = transport;
    }).catchError((error) {
      print('Error : couldn\'t set transport' + error.toString());
    });
  }

  void removeTransport() {
    this._usersInfoDoc.updateData(
        {
          "Transport": FieldValue.delete(),
        }
    ).then((result) {
      print('Transport removed');
      this._sharableUserInfo.transport = null;
    }).catchError((error) {
      print('Error : couldn\'t remove transport' + error.toString());
    });
  }

  //------------------------------------------Vehicles--------------------------------------------
  Future<void> getVehicles ()async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('vehicules').getDocuments();
    querySnapshot.documents.forEach((documentSnapshot){
      this._listVehicles.add(Vehicle.fromMap(documentSnapshot.data));
    });
  }
  Future<void> addVehicule(Vehicle v) async {
    await this._usersInfoDoc.collection('vehicules')
        .document(v.matricule).setData(v.vehicleToMap())
        .then((_) {
      this._listVehicles.add(v);
      print('vehicule added');
    }).catchError((error) {
      print('Couldn\'t add vehicule' + error.toString());
    });
  }

  Future<void> removeVehicule(Vehicle v) async {
    await this._usersInfoDoc.collection('vehicules')
        .document(v.matricule).delete()
        .then((_) {
      this._listVehicles.remove(v);
      print('Vehicule removed');
    }).catchError((error) {
      print('Couldn\'t remove vehicule' + error.toString());
    });
  }

  //------------------------------------------Historique--------------------------------------------
  // TODO test Historique
  void getHistorique () async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('historique').getDocuments();
    querySnapshot.documents.forEach((doc){
      _historique.add(TimePlace.fromMap(doc.data));
    });
  }
  void addToHistorique() {
    TimePlace timePlace = TimePlace(_sharableUserInfo.location, DateTime.now());
    Map<String, dynamic> data = timePlace.TimePlaceToMAp();
    data.putIfAbsent('Groupes', () => this.activeGroups());
    this._usersInfoDoc.collection('historique')
        .add(data)
        .whenComplete(() {
      print('Added to history');
    }).catchError((error) {
      print('could\'nt add to history');
    });
  }

  void supprimerHistorique() {
    //TODO _historique.supprimer();
  }

  void deleteGroupHistory(String groupe) async {
    QuerySnapshot querySnapshot = await this.getGroupHistory(groupe);
    querySnapshot.documents.forEach((doc) {
      List<String> groupes = doc.data['Groupes'];
      groupes.remove(groupe);
      doc.reference.updateData({
        'Groupes': groupes,
      });
    });
  }
  Future<QuerySnapshot> getGroupHistory(String groupe) async {
    return await _usersInfoDoc.collection('historique').where(
        'Groupes', arrayContains: groupe)
        .getDocuments();
  }



  //------------------------------------------Groupes--------------------------------------------
  //TODO test :
  Future<void> getUsersGroups() async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('groupes').getDocuments();
    querySnapshot.documents.forEach((documentSnapshot) async {
      bool active = documentSnapshot.data['active'];
      //Groupe groupe = await _firestoreService.getGroupInfo(documentSnapshot.documentID);
      this._groupes.putIfAbsent(documentSnapshot.documentID, ()=> active);
    });
  }
  Future<List<GroupHeader>> getUsersGroupsHeaders () async {
    if(groupes.isEmpty)
      await getUsersGroups();
    List<GroupHeader> headers = List<GroupHeader> ();
    _groupes.keys.forEach((groupID) async {
      GroupHeader groupeHeader = await _firestoreService.getGroupHeader(groupID);
      headers.add(groupeHeader);
    });
    return headers;
  }
  /*Stream<List<Groupe>> groupsStream () {
    Stream<QuerySnapshot> querySnapshotStream = this._usersInfoDoc.collection('groupes').getDocuments().asStream();
    return  querySnapshotStream.map((querySnapshot){
      List<Groupe> groupes = new List<Groupe> ();
      querySnapshot.documents.forEach((documentSnapshot) async {
        bool active = documentSnapshot.data['active'];
        Groupe groupe = await _firestoreService.getGroupInfo(documentSnapshot.documentID);
        this._groupes.putIfAbsent(groupe, ()=> active);
        groupes.add(groupe);
      });
      return groupes;
    });
  }*/
  //Adds a group to the user's groups list
  Future<void> addGroupe(String gid) async {
    DocumentReference doc = this._usersInfoDoc.collection('groupes').document(gid);
    doc.setData({
      'active': true,
    }).then((_) async {
      print('Group added');
      //Groupe groupe = await _firestoreService.getGroupInfo(gid);
      _groupes.putIfAbsent(gid, () => true);
    }).catchError(() {
      print('Couldn\'t add group');
    });
  }

  //Changes the user's active status for a specific groupe
  Future<void> changeActiveGroupe(String gid) async {
    DocumentReference doc = this._usersInfoDoc.collection('groupes').document(gid);
    bool b = _groupes[gid];
    doc.updateData({
      'active': !b,
    }).then((_) {
      print('Active status for group changed');
      _groupes.update(gid, (v) => !b);
    }).catchError(() {
      print('Couldn\'t change active status for group');
    });
  }

  //Removes a group from the user's groups list
  Future<void> removeGroupe(String gid) async {
    this._usersInfoDoc.collection('groupes').document(gid).delete()
    //TODO delete groupe discussion
    .then((_) {
      print('Group removed');
      _groupes.remove(gid);
    }).catchError(() {
      print('Couldn\'t remove group');
    });
  }

  //TODO leave group
  Future<void> leaveGroup (String gid) async {
    await removeGroupe(gid);
  }

  //Returns the list of groupes in which the user is active
  List<String> activeGroups() {
    List<String> activeGroupes = new List<String> ();
      _groupes.forEach((groupe, active) {
        if (active) {
          activeGroupes.add(groupe);
        }
      });
    return activeGroupes;
  }
  //------------------------------------------Boite de reception--------------------------------------------
  //------------------------------------------Messages personalisées----------------------------------------
  void addCustomMessage (String type, String message){
    this._usersInfoDoc.collection('MessagesPersonalisees').document(type).updateData({
      'Messages' : FieldValue.arrayUnion([message]),
    }).then((_){
      _messagesPersonalisees[type].add(message);
    });
  }
  void deleteCustomMessage (String type , String message){
    this._usersInfoDoc.collection('MessagesPersonalisees').document(type).updateData({
      'Messages' : FieldValue.arrayRemove([message]),
    }).then((_){
      _messagesPersonalisees[type].remove(message);
    });
  }
  Future<void> getCustomMessages () async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('MessagesPersonalisees').getDocuments();
    querySnapshot.documents.forEach((documentSnapshot){
      if(documentSnapshot.data.isNotEmpty)
        _messagesPersonalisees.putIfAbsent(EnumToString.fromString(TypeMessage.values, documentSnapshot.documentID),
                                                           () => documentSnapshot.data[['Messages']]);
    });
  }
  //Getter
  DocumentReference get usersInfoDoc => _usersInfoDoc;

  Map<String, bool> get groupes => _groupes;



  SharableUserInfo get sharableUserInfo => _sharableUserInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Utilisateur &&
              runtimeType == other.runtimeType &&
              _sharableUserInfo.id == other._sharableUserInfo.id;

  @override
  int get hashCode => _sharableUserInfo.id.hashCode;

}





