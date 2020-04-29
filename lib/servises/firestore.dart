import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps/classes/Groupe.dart';
import 'package:maps/classes/Request.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/groupe/groups.dart';

class FirestoreService {

  final Firestore _firestore = Firestore.instance;

  //-------------------------------------------Utilisateur--------------------------------------------
  //Create a new User doc of the user
  Future<void> createUserDoc(Utilisateur user) async
  {
    try {
      await _firestore.collection('users').document(user.sharableUserInfo.id).setData(user.sharableUserInfo.sharableUserInfoToMap()).then((result) {
        print("A document for your user has been created");
      }).catchError((error) {
        print("Error" + error.toString());
      });
      await addUsername(user.sharableUserInfo.id,user.sharableUserInfo.displayName, user.sharableUserInfo.username).then((_){
        print('user name added');
      });
    }
    catch (e) {
      print(e.code);
    }
  }
  Future<SharableUserInfo> getUserInfo(String id) async
  {
    try{
      SharableUserInfo u;
      Map<String,dynamic> data;
      Map<String,dynamic> publicData;
      DocumentSnapshot documentSnapshot = await _firestore.collection("users").document(id).get();
      if (documentSnapshot.exists){
          data = documentSnapshot.data;
          publicData = await getPublicInfo(data['Username']);
          data.addAll(publicData);
          print(data);
          u = SharableUserInfo.fromMap(id,data);
      }
      else
      {
        print('Couldn\'t find user\'s data');
        u = null;
      }
      return u;
    }
    catch(e){
      print('error while getting user info'+e.toString());
      return null;
    }
  }

  Future<Map<String,dynamic>> getPublicInfo(String username) async
  {
    Map<String,dynamic> publicData;
    DocumentSnapshot publicDocumentSnapshot = await _firestore.collection('usernames').document(username).get();
    if (publicDocumentSnapshot.exists){
      publicData = publicDocumentSnapshot.data;
    }
    else
    {
      print('Couldn\'t find public user\'s data');
    }
    return publicData;
  }
  //Affichage des information
  void afficher(String uid){

  }

  Future<void> addToGroupe (String gid,String uid) async {
    await _firestore.collection('users').document(uid).collection('groupes').document('groupes').updateData({
      gid : true,
    }).then((_){
      print('Group added');
    }).catchError((){
      print('Couldn\'t add group');
    });
    await _firestore.collection("groups").document(gid).updateData({
      'Members' : FieldValue.arrayUnion([uid]),
    })
        .then((_){
      print('member added');
    })
        .catchError((error){
      print('Couldn\'t add member');
    });
  }

  //-------------------------------------------Groupes--------------------------------------------
  Future<Group> createGroupDoc (String nom,String adminID,List<String> members) async
  {
    List<String> membersUsernames = new List<String> ();

    DocumentReference groupDoc = await _firestore.collection("groups")
        .add(Group.groupMap(nom,adminID));
    String GID = groupDoc.documentID ;
    groupDoc.updateData({
      'GID' : GID,
    });
    return new Group(GID,nom,adminID);
  }
  Future<GroupHeader> getGroupHeader(String gid) async
  {
    try{
      GroupHeader g ;
      await _firestore.collection("groups").document(gid).get().then((grpData){
        if(grpData.exists)
        {
          Map<String,dynamic> data = grpData.data;
          g =GroupHeader(gid, data);
          print(g.gid+' '+g.name+' '+g.photo.toString());
        }
        else
        {
          print('Couldn\'t find group\'s data');
          g = null;
        }
      }).catchError((error){
        print('Something went wrong'+error.toString());
      });
      return g;
    }
    catch(e){
      print('error while getting group\'s info'+e.code);
      return null;
    }
  }
  Future<Group> getGroupInfo(String gid) async
  {
    try{
      Group u;
      await _firestore.collection("groups").document(gid).get().then((grpData){
        if(grpData.exists)
        {
          Map<String,dynamic> data = grpData.data;
          Group g = Group.old(gid,data);
          print(g.gid+' '+g.nom+' '+g.adminUsename);
        }
        else
        {
          print('Couldn\'t find group\'s data');
          u = null;
        }
      }).catchError((error){
        print('Something went wrong'+error.toString());
      });
      return u;
    }
    catch(e){
      print('error while getting group\'s info'+e.code);
      return null;
    }
  }
  //--------------------------------------------Invitations--------------------------------------------
  Request sendInvitationFromGroup(String toUsername,String fromUsername,String gid,String text){
    Request r ;
    String requestID;
    _firestore.collection('invitationsFromGroup').add({
      'ToUsername' : toUsername ,
      'FromUsername' :fromUsername,
      'GID' : gid,
      'Accepted' : false ,
      'Text' : text,
    }).then((doc){
        requestID = doc.documentID;

        doc.updateData({
          'RequestID': requestID,
        })
            .then((_){
                print('request added');
                r =  RequestFromGroupe(requestID, toUsername, fromUsername, gid ,text);
        })
            .catchError((e){
                print('Something went wrong clouldn\'t add ID'+e.code);
      });
    }).catchError((e){
        print('Couldn\'t add invitation'+e.code);
    });
    return r;
  }
  Request sendInvitationFromUser(String toUID,String fromUID,String gid,String text){
    Request r ;
    String requestID;
    _firestore.collection('invitationsFromUser').add({
      'ToUID' : toUID ,
      'FromID' :fromUID,
      'GID' : gid,
      'Accepted' : false ,
      'Text' : text,
    }).then((doc){
      requestID = doc.documentID;
      doc.updateData({
        'RequestID': requestID,
      })
          .then((_){
        print('request added');
        r =  RequestFromUser(requestID, toUID, fromUID, gid ,text);
      })
          .catchError((e){
        print('Something went wrong clouldn\'t add ID'+e.code);
      });
    }).catchError((e){
      print('Couldn\'t add invitation'+e.code);
    });
    return r;
  }

  void deleteInvitation (Request request) async{
    await _firestore.collection('invitations').document(request.requestID).delete().then((_){
      print('Invitation deleted');
    }).catchError((e){
      print('Couldn\'t delete invitation');
    });
  }
  //----------------------------Usernames----------------------------------------------
  Map<String,dynamic> usernameMap (String uid,String displayName){
    return {
      'UID' : uid,
      'DisplayName' : displayName,
      'Photo' : false ,
    };
  }
   Future<bool> userNameExists (String username) async {
        DocumentSnapshot snapshot = await _firestore.collection('usernames').document(username).get() ;
        return snapshot.exists ;
  }

  Future<void> addUsername (String uid,String displayName,String username)async {
    DocumentReference usernameDoc = _firestore.collection('usernames').document(username);
    if (!await userNameExists(username)){
      usernameDoc.setData(usernameMap(uid,displayName));
    }
    else
      throw UsenameExistsException();

    /*_firestore.runTransaction( (transaction){
      // DocumentSnapshot documentSnapshot = await
      transaction.get(usernameDoc).then((documentSnapshot){
        if(documentSnapshot.exists)
          throw UsenameExistsException();
        else{
          usernameDoc.setData(usernameMap(uid,displayName));
        }
      });
      return null;
    });*/

  }
  //----------------------------Usernames----------------------------------------------
  Future<List<GroupHeader>> getPublicGroupes(Pattern pattern) async {
    List<GroupHeader> publicGroupes  = List<GroupHeader>();
    QuerySnapshot snapshot = await _firestore.collection('publicGroupes').where('Nom',isGreaterThanOrEqualTo: pattern)
                                                                              .where('Nom',isLessThan: next(pattern)).getDocuments();
    snapshot.documents.forEach((documentSnapshot){
      if(documentSnapshot.exists){
        String nom = documentSnapshot.data['Nom'];
        if(nom.startsWith(pattern)){
          publicGroupes.add(GroupHeader(documentSnapshot.documentID,documentSnapshot.data));
        }
      }
    });
    return publicGroupes;
  }
  String next(String string){
    return  string.substring(0,string.length - 2) +
                    String.fromCharCode(string.codeUnitAt(string.length-1)+ 1);
  }
  //Others
  GeoPoint firestorePosition (Position position ){
    return GeoPoint(position.latitude, position.longitude);
  }
  Timestamp firestoreDateTime(DateTime date){
    return Timestamp.fromDate(date);
  }
}
class UsenameExistsException implements Exception {
  String _code ;
  UsenameExistsException(){this._code = 'USERNAME_EXISTS';}
  String get code => _code;
}

