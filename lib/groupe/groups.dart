import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:maps/classes/Groupe.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/groupe/groupMembers.dart';
import 'package:maps/servises/firestore.dart';
import 'package:maps/servises/storage.dart';
import 'package:provider/provider.dart';
import 'package:maps/Wrapper.dart';

class Groups extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<Groups> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  Utilisateur utilisateur ;

  @override
  Widget build(BuildContext context){
    setState(() {
      utilisateur = Provider.of<User>(context).utilisateur;
    });
    return Container(
      child : Column(
        children: <Widget>[
          TypeAheadField (
            suggestionsCallback: (pattern) async {
              try{
                return await _firestoreService.getPublicGroupes(pattern);
              }
              catch(e){
                return null;
              }
            },
            itemBuilder: (context,suggestion) {
              GroupHeader group = suggestion;
              return ListTile(
                title: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: _storageService.groupsImage(group.photo, group.groupPhoto),
                    ),
                    Text(group.name),
                  ],
                ),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (suggestion) {
              GroupHeader publicGroupe = suggestion;
              //TODO show public group's info
            },
          ),

          FutureBuilder(
            future: _showGroup(),
            builder: (BuildContext context,asyncSnapshot){
              if(asyncSnapshot.data == null){
                return Container(
                  child: Text('Loading....'),
                );
              }
              else {
                return ListView.builder(
                    itemCount: asyncSnapshot.data.length,
                    itemBuilder: (BuildContext context,int index){
                      GroupHeader groupHeader = asyncSnapshot.data[index];
                      return ListTile(
                        onTap: () async {
                          Group group = await _firestoreService.getGroupInfo(groupHeader.gid);
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Members(group: group,)));
                        } ,
                        title: Row(
                          children: <Widget>[
                            CircleAvatar(
                               backgroundImage: _storageService.groupsImage(groupHeader.photo, groupHeader.groupPhoto),
                            ),

                            Text(groupHeader.name),
                          ],
                        ),
                        //TODO onLongPress: , ??? delete conv , notofication  maybe
                      );
                    },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<GroupHeader>> _showGroup () async {
    return await utilisateur.getUsersGroupsHeaders();
  }
}
