import 'package:cloud_firestore/cloud_firestore.dart';

class Message implements Comparable<Message>{
  String _messageID ;
  String _text;
  TypeMessage _type;
  DateTime _dateTime ;
  String _expediteur;
  bool _sent ;
  bool _delivered ;
  Map<String,bool> _seenBy ; //.configure

  Message(String messageID,String text,TypeMessage type,DateTime datetime,String expediteur,bool sent,bool delivered,Map<String,bool> seenBy){
    _messageID = messageID;
    _text = text;
    _type = type;
    _dateTime = datetime ;
    _expediteur = expediteur;
    _sent = sent;
    _delivered = delivered;
    _seenBy = seenBy ;
  }
  Message.from(Map<String,dynamic> message){
    _messageID = message['MessageID'];
    _text = message['Text'];
    _type = message['Type'];
    Timestamp timestamp = message['DateTime'];
    _dateTime =  timestamp.toDate();
    _expediteur = message['From'];
    _sent = true;
    _delivered = message['Delivered'];
    _seenBy = message['SeenBy'] ;
  }
   //Converting a Message to a Map<String,dynamic> for it to be added to firestore
  Map<String,dynamic> messageToMap () {
    return {
      'MessageID' : this._messageID,
      'Text' : this._text,
      'Type' : this._type.toString(),
      'DateTime' : Timestamp.fromDate(this._dateTime),
      'From' : this._expediteur,
      'Delivered' : this._delivered,
      'SeenBy' : this._seenBy,
    };
  }

  @override
  int compareTo(Message message){
    return this._dateTime.compareTo(message.dateTime);
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Message &&
              runtimeType == other.runtimeType &&
              _messageID == other._messageID;

  @override
  int get hashCode => _messageID.hashCode;
  
  //-------------------------Getters------------------------------
  String get messageID =>_messageID;

  bool get delivered => _delivered;

  Map<String, bool> get seenBy => _seenBy;

  bool get sent => _sent;

  DateTime get dateTime => _dateTime;

  String get expediteur => _expediteur;

  String get text => _text;

  TypeMessage get type => _type;
  //-------------------------Setters------------------------------
  void setSent() {
    _sent = true;
  }
  void setDeliverd() {
    _delivered = true;
  }
  void setSeen(String username) {
    _seenBy.update(username, (bool)=> true);
  }
}
class Alerte extends Message {

  Alerte(String messageID,String text,TypeMessage type,DateTime datetime,String expediteur,bool sent,bool delivered,Map<String,bool> seenBy) :
        super (messageID,text,type,datetime,expediteur,sent,delivered,seenBy);
}
enum  TypeMessage {
  Meteo,Accident,EtatRoute,Vitesse,Distance,AboutGroupe
}