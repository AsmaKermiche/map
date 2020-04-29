import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maps/Wrapper.dart';
import 'package:maps/classes/Groupe.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/servises/storage.dart';
import 'package:provider/provider.dart';

class Members extends StatefulWidget {
  final Group group ;
  Members({Key key, @required this.group}) : super(key: key);
  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final StorageService _storageService = StorageService();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: widget.group.getMembers(),
        builder: (BuildContext context,AsyncSnapshot asyncSnapshot){
          if(asyncSnapshot.data == null){
            return Container(
              child: Text('Loading....'),
            );
          }
          else {
            return ListView.builder(
              itemCount: asyncSnapshot.data.length,
              itemBuilder: (BuildContext context,int index){
                Member member = asyncSnapshot.data[index];
                return ListTile(
                  title: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: _storageService.usersPhoto(member.membersInfo),
                      ),
                      Text(
                          Provider.of<User>(context).utilisateur.sharableUserInfo.id != member.membersInfo.id
                                                                  ? member.membersInfo.displayName
                                                                  : 'You'
                      ),
                    ],
                  ),
                  // TODO onTap: , ??
                  //TODO onLongPress: , ??
                );
              },
            );
          }
        },
      ),
    );
  }
}
