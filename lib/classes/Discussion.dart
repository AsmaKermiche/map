import 'package:maps/classes/Message.dart';

class Discussion{
  List<Message> _liste_messages ;

  Discussion (){
    _liste_messages = new List();
  }
  Discussion.old (List<Message> messages){
    _liste_messages = messages;
  }
  Future<void> addMesssage(Message message) async{

  }
  Future<void> removeMessageForEveryone (Message message) async {

  }
  Future<void> removeMessage () async {

  }
  void deleteConversation (){
    _liste_messages.clear();
  }
}