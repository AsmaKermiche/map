import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maps/classes/Message.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/classes/TimePlace.dart';
import 'package:maps/servises/firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

class GroupHeader {
  String gid;
  String name;
  bool photo ;
  String groupPhoto ;
  GroupHeader (String gid,Map<String,dynamic> data){
    this.gid = gid ;
    name = data['Nom'];
    photo = data['Photo'];
    groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  Map<String,dynamic> groupHeaderToMap() => {
    'GID': gid,
    'Nom' : name,
    'Photo' :photo,
  } ;
}
class Group{
  //Public
  String _gid;
  String _nom;
  bool _photo ;
  bool _visible ;
  //Private
  String _adminID;
  List<Member> _members;
  List<Message> _discussion;
  DateTime _lastReadMessage;
  String _invitationCode;
  //Optional :
  GeoPoint _destination ;
  DateTime _dateDepart ;
  TypeGroupe _type;

  //-----------------------------BDD--------------------------------------------
  final Firestore _firestore = Firestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  DocumentReference _groupInfoDoc ;
  CollectionReference _discussionCollection;
  String _groupPhoto ;
  //-----------------------------Constructors-----------------------------
  Group (String id,String nom,String adminID){
    this._gid = id;
    this._adminID = adminID;
    this._nom = nom;
    this._visible = true;
    this._photo = false ;
    this._members = new List<Member>();
    this._discussion = new List<Message>();
    this._lastReadMessage = DateTime.now();
    //TODO invitation code
    this._destination = null;
    this._dateDepart = null;
    this._type = null;
    this._groupInfoDoc = _firestore.collection("groups").document(this._gid);
    this._discussionCollection = this._groupInfoDoc.collection('Discussion');
    this._groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  Group.old(String gid,Map<String,dynamic> groupeData){
    this._gid = gid;
    this._nom = groupeData['Nom'];
    this._photo = groupeData['Photo'];
    this._adminID = groupeData['Admin'];
    this._visible = groupeData['Visible'];
    //TODO invitation code
    //TODO amina hna ana 5dmt b geoPoint fiha altitude w longitude
    if(groupeData.containsKey('LieuArrive')){
      _destination = groupeData['LieuArrive'];
    }
    if(groupeData.containsKey('DateDepart')){
      Timestamp timestamp = groupeData['DateDepart'];
      this._dateDepart = timestamp.toDate();
    }
    if(groupeData.containsKey('Type')){
      String type = groupeData['Type'];
      this._type = EnumToString.fromString(TypeGroupe.values, type);
    }
    this._members = new List<Member>();
    this._discussion = new List<Message>();
    this._lastReadMessage = groupeData['LastReadMessage'];
    this._groupInfoDoc = _firestore.collection("groups").document(this._gid);
    this._discussionCollection = this._groupInfoDoc.collection('Discussion');
    this._groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  static Map<String,dynamic> groupMap (String nom,String adminID) {
    Map<String,Timestamp> members = new Map<String,Timestamp> ();
    members.putIfAbsent(adminID, () => Timestamp.now());
    return {
      'Nom' : nom,
      'Admin' : adminID,
      'LastReadMessage' : Timestamp.now() ,
      'Visible' : true,
      'Photo' : false,
      'Members' : members,
    };
  }

  void updateGroupe(Map<String,dynamic> groupeData){
    this._nom = groupeData['Nom'];
    this._photo = groupeData['Photo'];
    this._adminID = groupeData['Admin'];
    this._visible = groupeData['Visible'];
    //TODO invitation code
    //TODO amina hna ana 5dmt b geoPoint fiha altitude w longitude
    if(groupeData.containsKey('LieuArrive')){
      _destination = groupeData['LieuArrive'];
    }
    if(groupeData.containsKey('DateDepart')){
      Timestamp timestamp = groupeData['DateDepart'];
      this._dateDepart = timestamp.toDate();
    }
    if(groupeData.containsKey('Type')){
      String type = groupeData['Type'];
      this._type = EnumToString.fromString(TypeGroupe.values, type);
    }
  }
  //-----------------------------Setters-----------------------------
  Future<void> setNom (String nom) async {
    await this._groupInfoDoc.updateData({
      'Nom' : nom,
    }).then((_){
      print('Group\'s name has been set');
      this._nom = nom;
    }).catchError((error){
      print('couldn\'t set name');
    });
  }
  /*Future<void> setType (TypeGroupe type) async {
    await this._groupInfoDoc.updateData({
      'Type' : type.toString(),
    }).then((_){
      print('Group\'s type has been set');
      this._type = type;
    }).catchError((error){
      print('couldn\'t set type');
    });
  }*/
  Future<void> changeVisibility() async {
    bool b = !_visible;
    await this._groupInfoDoc.updateData(
        {
          "Visible": b,
        }
    ).then((result) {
      _visible = b;
      print("visibility changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }
  Future<void> setLieuArrive (GeoPoint lieuArrive) async {
      await this._groupInfoDoc.updateData({
        'LieuArrive' : lieuArrive,
      })
        .then((_){
            print('Destination set');
            this._destination = lieuArrive;
         })
        .catchError((error){
            print('Couldn\'t set destination');
        });
  }
  Future<void> setDateDepart (DateTime dateDepart) async {
    await this._groupInfoDoc.updateData({
      'DateDepart' : _firestoreService.firestoreDateTime(dateDepart),
    })
        .then((_){
      print('time set');
      this._dateDepart = dateDepart;
    })
        .catchError((error){
      print('Couldn\'t set time');
    });
  }

  //Remove
  Future<void> removeDateDepart () async {
    await this._groupInfoDoc.updateData({
      'DateDepart' : FieldValue.delete(),
    })
        .then((_){
      print('time deleted');
      this._dateDepart = null;
    })
        .catchError((error){
      print('Couldn\'t delete time');
    });
  }
  Future<void> removeLieuArrive () async {
    await this._groupInfoDoc.updateData({
      'LieuArrive' : FieldValue.delete(),
    })
        .then((_){
      print('Destination removed');
      this._destination = null;
    })
        .catchError((error){
      print('Couldn\'t remove destination');
    });

  }
  Future<void> removeType () async {
    await this._groupInfoDoc.updateData({
      'Type' : FieldValue.delete(),
    })
        .then((_){
      print('Type removed');
      this._type = null;

    })
        .catchError((error){
      print('Couldn\'t remove destination');
    });
  }
  Future<void> setLastReadMessage () async {
    await this._groupInfoDoc.updateData({
      'LastReadMessage' : Timestamp.now(),
    })
      .then((_){
      print('Last read message set');
      this._lastReadMessage = DateTime.now();
    })
      .catchError((error){
    print('Couldn\'t set last read message');
    });
  }
  //------------------------------------Photo----------------------------------------
  Future<void> setPhoto() async {
    File file;
    file = await FilePicker.getFile(type: FileType.image);
    await _uploadPhoto(file).then((_) {
      print('photo set');
    }).catchError((error) {
      print('could\'nt set photo');
    });
  }

  Future<String> _uploadPhoto(File file) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(_groupPhoto);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print('photo url'+url);
  }

  Future<void> deletePhoto() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(_groupPhoto);
    storageReference.delete().whenComplete(() {
      print('Profile photo deleted');
    }).catchError((error) {
      print('Could\'t delete profile photo');
    });
  }

  //-----------------------------------Members----------------------------------------
  //TODO
  Member member(String uid){
    Member thisMember;
    _members.forEach((member){
      if(member.membersInfo.id==uid)
        thisMember = member;
    });
    return thisMember;
  }
  Future<void> addMember (String uid) async{
    DateTime dateTime = DateTime.now();
    SharableUserInfo sharableUserInfo = await _firestoreService.getUserInfo(uid);
    await this._groupInfoDoc.updateData({
      //'Members' : FieldValue.arrayUnion([member.membersInfo.id]),
      'Members.'+uid : Timestamp.fromDate(dateTime),
    })
        .then((_){
      print('member added');
      this._members.add(Member(gid,dateTime,sharableUserInfo));
    })
        .catchError((error){
      print('Couldn\'t add member');
    });
  }
  Future<void> removeMember (Member member) async {
    if(member.membersInfo.id!=this.adminUsename){
      await this._groupInfoDoc.updateData({
        'Members.'+member.membersInfo.id : FieldValue.delete(),
      })
          .then((_){
        print('member deleted');
        this._members.remove(member);
      })
          .catchError((error){
        print('Couldn\'t delete member');
      });
    }
    else
      print('You are the admin of this group please choose asign someone to replace u before leaving');
  }
  Future<bool> getActiveMember (String uid) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection('users').document(uid).collection('groupes').document(_gid).get();
    if(documentSnapshot.exists)
      return  documentSnapshot.data['active'];
    else
      return false ;
  }
  Future<void> getMembersInfo (String memberID,DateTime dateTime) async {
    bool active = await getActiveMember(memberID);
    SharableUserInfo sharableUserInfo;
    if (active){
      sharableUserInfo = await _firestoreService.getUserInfo(memberID);
      _members.add(Member(memberID, dateTime, sharableUserInfo));
    }
    else{
      //TODO Something to do with offline support and serialisation
      print('Offline');
    }
  }
   Future<List<Member>> getMembers () async {
    if (_members.isEmpty){
      DocumentSnapshot documentSnapshot = await _groupInfoDoc.get();
      if (documentSnapshot.exists){
        Map<String,Timestamp> membersIDS = documentSnapshot.data['Members'];
        membersIDS.forEach((memberID,timestamp){
          getMembersInfo(memberID, timestamp.toDate());
        });
        return _members;
      }
      else{
        print('Group\'s doc does not exist this should not happen ');
        return null;
      }
    }
    else
      return _members;
  }
  Future<List<TimePlace>> getHistoryMember(String memberID) async {
    List<TimePlace> historique = List<TimePlace>();
    QuerySnapshot querySnapshot = await  _firestore.collection('users').document(memberID).collection('historique').where(
        'Groupes', arrayContains: this._gid).getDocuments();
    querySnapshot.documents.forEach((doc){
      historique.add(TimePlace.fromMap(doc.data));
    });
    return historique;
  }

  //----------------------------------Admin-----------------------------------------
  Future<void> setAdminWith (String newAdminID) async {
    await this._groupInfoDoc.updateData({
      'Admin' : newAdminID,
    })
        .then((_){
      print('Admin set');
      this._adminID = newAdminID;

    })
        .catchError((error){
      print('Couldn\'t set Admin');
    });
  }
  Future<void> setAdmin () async {
    if(this._type==null || this._type != TypeGroupe.Family)
      _members.sort();
    else
      _members.sort((member1,member2){
        return member1.membersInfo.compareTo(member2.membersInfo);
      });

    String newAdminID;
    if(_members[0].membersInfo.id == _adminID){
      newAdminID = _members[1].membersInfo.id;
    }
    else{
      newAdminID = _members[0].membersInfo.id;
    }
    await setAdminWith(newAdminID);
  }
  Future<void> removeAdminAndSet () async {
    String adminUsername = this._adminID;
    setAdmin()
        .then((_)=> removeMember(member(adminUsername))
                                .then((_)=>print('Member removed succesfully'))
                                    .catchError((error)=>print('Could\'nt remove member'))
          .catchError((error)=>print('Couldn\'t set admin plz try later')));
  }

  //------------------------------------Discussion-----------------------------------------------
  Future<void> addMesssage(String text,TypeMessage type,String expediteur) async{
    DocumentReference messageDoc = await _discussionCollection.add({});
    Map<String,bool> seenBy = new Map<String,bool> ();
    this._members.forEach((member){
      if(member.membersInfo.id==expediteur)
        seenBy.putIfAbsent(member.membersInfo.id, ()=>true);
      else
        seenBy.putIfAbsent(member.membersInfo.id, ()=>false);
    });
    Message message = Message(messageDoc.documentID, text, type, DateTime.now(), expediteur, false, false, seenBy);
    await messageDoc.setData(message.messageToMap()).then((_)=>  message.setSent())
        .catchError((error){
              print('Message can\'t be sent '+error.toString());
        });
  }
  Future<void> removeMessageForEveryone (String username,Message message) async {
    if(username == message.expediteur){
      await _discussionCollection.document(message.messageID).delete();
    }
  }
  Future<void> setMessageSeen (String username,Message message) async{
    await _discussionCollection.document(message.messageID).updateData({
      'SeenBy.$username' : true,
    });
  }
  Future<void> setMessageDelivered (String messageID) async{
    await _discussionCollection.document(messageID).updateData({
      'Delivered' : true,
    });
  }

  //-----------------------------Listening to changes -------------------------------
  void listenToChangesInGroup () {
    //Listen to changes in members info :
    //Listen to changes on the groupInfoDoc :
  }
  Stream<DocumentSnapshot> groupsInfoStream (){
    return _groupInfoDoc.snapshots();
  }
  Stream<Member> _membersStream () {

  }
  //On a member :
  void _listenToChanges (Member member) {
    _firestore.collection('users').where('UID' ,isEqualTo: member.membersInfo.id).snapshots().listen((querySnapshot){
      querySnapshot.documentChanges.forEach((documentChange){
        switch(documentChange.type){
          case DocumentChangeType.modified :
            _onMemberGroupInfoModified(documentChange.document.data,member);
            break;
          case DocumentChangeType.removed :
            _onMemberRemoved(member);
            break;
          default :
            break;
        }
      });
    });
    _firestore.collection('usernames').where('UID' ,isEqualTo: member.membersInfo.id).snapshots().listen((querySnapshot){
      querySnapshot.documentChanges.forEach((documentChange){
        switch(documentChange.type){
          case DocumentChangeType.modified :
            _onMemberPublicInfoModified(documentChange.document.data,member);
            break;
          default :
            break;
        }
      });
    });
  }
  void _onMemberGroupInfoModified (Map<String,dynamic> data,Member member){
      member.membersInfo.setInfoGroup(data);
  }
  void _onMemberPublicInfoModified(Map<String,dynamic> data,Member member){
    member.membersInfo.setInfoPublic(data);
  }
  void _onMemberRemoved (Member member) {
    if(member.membersInfo.id == _adminID){
      removeAdminAndSet();
    }
    else
      removeMember(member);
    addMesssage('This groupe has a new admin now : $_adminID', TypeMessage.AboutGroupe, '') ;
  }
  //On discussion
  void _listenToChangesDiscussion (){
   _discussionCollection.where('DateTime',isGreaterThan: _lastReadMessage).snapshots().listen((querySnapshot){
      querySnapshot.documentChanges.forEach((documentChange){
        switch(documentChange.type){
          case DocumentChangeType.modified :
            break;
          case DocumentChangeType.removed :
            break;
          case DocumentChangeType.added :
             Message message = Message.from(documentChange.document.data) ;
             setMessageDelivered(message.messageID).then((_) => _discussion.add(message));
            break;
        }
      });
    });
  }


  //-----------------------------------------------------------------------------------------------

  //Getters
  String get nom => _nom;

  String get adminUsename => _adminID;

  String get gid => _gid;

  GeoPoint get lieuArrive => _destination;

  TypeGroupe get type => _type;

  DateTime get dateDepart => _dateDepart;

  List<Message> get discussion => _discussion;

  bool get visible => _visible;

  String get adminID => _adminID;

  bool get photo => _photo;

  String get groupPhoto => _groupPhoto;

  Stream<DocumentSnapshot> get snapShots => _groupInfoDoc.snapshots();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Group &&
              runtimeType == other.runtimeType &&
              _gid == other._gid;

  @override
  int get hashCode => _gid.hashCode;


}

enum TypeGroupe {
  Family,Friends,Work,Other
}
class Member implements Comparable<Member>{
    SharableUserInfo _membersInfo ;
    DateTime _dateTime ;
    Member (String id,DateTime dateTime,SharableUserInfo sharableUserInfo){
      _membersInfo = sharableUserInfo;
      _dateTime = dateTime;
    }
    @override
    int compareTo(Member member){
      return - dateTime.compareTo(member.dateTime);
    }
    DateTime get dateTime => _dateTime;
    SharableUserInfo get membersInfo => _membersInfo;
}
