/*import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ourwonderfullapp/classes/Message.dart';

@immutable

class MessagesService {


  final String title;
  final String body;

  const MessagesService ( {

     @required this.title,
     @required this.body,

});

}

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  MessagesService() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
    );
  }

//------------------------------Receiving a message-----------------------------
  Message exctractJSONNotification(){
    /*
    final Map<String, Item> _items = <String, Item>{};
    Item _itemForMessage(Map<String, dynamic> message) {
    final dynamic data = message['data'] ?? message;
    final String itemId = data['id'];
    final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
     .._matchteam = data['matchteam']
      .._score = data['score'];
    return item;
    }
    */
  }
  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    /*
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }*/

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      // create custom message object
      // set delivered to true if it's false in firestore
    }

    // Or do other work.
  }

  void _onMessageFunction() {
      //set seen by me to true
  }

  void _onResumeFunction() {
    //set seen by me to true
  }

  void _onLaunchFunction() {
    //set seen by me to true
  }
//----------------------------Sending a message---------------------------------
  void sendMessage (){
    //title : name of the groupe
    //body : fromWhome : the message
    // additional data (payload): datetime , uid , gid , type ,
    //our custom message : all of that + sent = false , delivered = false , bools in map = false
    // when it's sent add it to firestore
  }
}
*/
