import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps/servises/firestore.dart';

abstract class Request {
  String _requestID;
  String _toUsername;
  String _fromUsename;
  bool _accepted ;
  String _gid;
  String _text;
  DateTime _dateTime;
  Request (String requestID, String toUsername,String fromUsername,String gid,String text){
    this._requestID = requestID;
    this._toUsername = toUsername;
    this._fromUsename = fromUsername;
    this._accepted = false;
    this._gid = gid;
    this._text = text;
    this._dateTime = DateTime.now();
  }

  Map<String,dynamic> requestToMap()=>
    {
      'ToUsername' : _toUsername ,
      'FromUsername' :_fromUsename,
      'GID' : _gid,
      'Accepted' : false ,
      'Text' : _text,
      'DateTime' : DateTime.now() ,
    };
  //SETTERS :
  void setAccepted(bool value) {
    Firestore firestore = Firestore.instance;
    firestore.collection('invitations').document(this._requestID).updateData({
      'Accepted' : value ,
    }).then((_){
      print('Invitation accepted');
      this._accepted = value ;
    }).catchError((e){
      print('Something went wrong clould\'nt accept invitation '+e.code);
    });
  }

  //GETTERS :
  String get requestID => _requestID;

  String get toUID => _toUsername;

  bool get accepted => _accepted;

  String get gid => _gid;

  String get fromUID => _fromUsename;

  DateTime get dateTime => _dateTime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Request &&
              runtimeType == other.runtimeType &&
              _requestID == other._requestID;

  @override
  int get hashCode => _requestID.hashCode;

}

class RequestFromGroupe extends Request{

  RequestFromGroupe(String requestID, String toUID,String fromUID,String gid,String text) : super(requestID,toUID,fromUID,gid,text);

  @override
  void setAccepted(bool value){
    super.setAccepted(value);
    if(value){
      FirestoreService firestoreService = FirestoreService();
      firestoreService.addToGroupe(gid, _toUsername);
      //TODO add the the discussion of the groupe that a new ser has been added
    }
  }
}

class RequestFromUser extends Request {

  String _text;
  RequestFromUser(String requestID, String toUID,String fromUID,String gid,String text) : super(requestID,toUID,fromUID,gid,text);

  @override
  void setAccepted(bool value){
    super.setAccepted(value);
    if(value){
      FirestoreService firestoreService = FirestoreService();
      firestoreService.addToGroupe(gid, _fromUsename);
      //TODO add the the discussion of the groupe that a new ser has been added
    }
  }
}