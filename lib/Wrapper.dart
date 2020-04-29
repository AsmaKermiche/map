import 'package:flutter/material.dart';
import 'package:maps/authentication/Connection.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/groupe/groups.dart';
import 'package:maps/home/Home.dart';
import 'package:maps/servises/DeviceInfoService.dart';
import 'package:provider/provider.dart';
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return either Home or Authenticate depending on the Firebase.Auth instance
    if (Provider.of<User>(context).utilisateur == null)
      return Connection () ;
    else
    {
      return Groups();
    }

  }
}

class User extends ChangeNotifier {
  Utilisateur _utilisateur;
  void setUtilisateur (Utilisateur utilisateur){
    _utilisateur = utilisateur;
    notifyListeners();
  }
  void onUserModified (){
    notifyListeners();
  }
 Utilisateur get utilisateur => _utilisateur;
}