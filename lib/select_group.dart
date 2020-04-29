import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps/Wrapper.dart';
import 'package:maps/classes/Groupe.dart';
import 'package:maps/servises/firestore.dart';
import 'package:maps/servises/storage.dart';
import 'package:provider/provider.dart';

import 'direct_select_container.dart';
import 'direct_select_item.dart';
import 'direct_select_list.dart';
import 'package:flutter/material.dart';


class Mygroup extends StatefulWidget {
  Mygroup({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() =>
      _MyHomePageState();
}

class _MyHomePageState extends State<Mygroup> {

  final buttonPadding = const EdgeInsets.fromLTRB(0, 30, 0, 0);
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService() ;

  Group selectedGroup ;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

     DirectSelectContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      //---------------------------------------GroupSelector------------------------------------------------------
                      FutureBuilder(
                          future: Provider.of<User>(context).utilisateur.getUsersGroupsHeaders(),
                          builder: (buildContext,asyncSnapshot)
                          {
                            if (asyncSnapshot.data == null)
                              //TODO Asma i'm not sure what this should be , it's for when we're loading data from the DB
                              return Text('Loading...') ;
                            else  {
                              List<GroupHeader> groups = asyncSnapshot.data ;
                              return Column(
                                children: [
                                  Padding(
                                    padding: buttonPadding,
                                    child: Container(
                                      decoration: _getShadowDecoration(),
                                      child: Card(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Expanded(
                                                  child: Padding(
                                                      child: DirectSelectList<GroupHeader>(
                                                        values: groups,
                                                        defaultItemIndex: 0,
                                                        onItemSelectedListener: (groupHeader, int, context) async {
                                                          try {
                                                            Group group = await _firestoreService.getGroupInfo(groupHeader.gid);
                                                            setState(() {
                                                              selectedGroup = group ;
                                                            });
                                                          } catch (e) {
                                                            //TODO show something saying something went wrong
                                                            print(e);
                                                          }
                                                        },
                                                        itemBuilder: (GroupHeader value) => getDropDownMenuItem(value), focusedItemDecoration: _getDslDecoration(),
                                                      ),
                                                      padding: EdgeInsets.only(left: 12)
                                                  )
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(right: 8),
                                                child: _getDropdownIcon(),
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                      ),
                      //----------------------------------------------------------------------------------------------------------
                      SizedBox(height: 20.0),
                      SizedBox(height: 15.0),
                      //------------------------------------------Where we should show the group's info------------------------------------------
                      onGroupSelected(),
                      //-------------------------------------------------------------------------------------------------------------------------
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
  //Function to check whether there's a selected group or not
  Widget onGroupSelected () {
    if (selectedGroup == null)
      return Text ('Hello , select a group to start tracking'); //TODO Asma
    else
      return StreamBuilder(
        stream: selectedGroup.snapShots,
        builder: (buildContext,asyncSnapshot) {
          DocumentSnapshot documentSnapshot = asyncSnapshot.data;
          if (documentSnapshot != null)
            selectedGroup.updateGroupe(documentSnapshot.data);
          //TODO  what needs to be shown for the group
          return null;
        } ,
      );
  }

  //-------------------------------------Group selector ---------------------------------------------
  DirectSelectItem<GroupHeader> getDropDownMenuItem(GroupHeader value) {
    return DirectSelectItem<GroupHeader>(
        itemHeight: 45,
        value: value,
        itemBuilder: (context, value) {
          return Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: _storageService.groupsImage(value.photo, value.groupPhoto),
              ),
              Text(value.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          );
          /*return Text(value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          );*/
        });
  }

  _getDslDecoration() {
    return BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(width: 1, color: Colors.orangeAccent),
          top: BorderSide(width: 1, color: Colors.orangeAccent),
        ));
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black45.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 10.0,
        ),
      ],
    );
  }

  Icon _getDropdownIcon() {
    return Icon(
      Icons.unfold_more,
      color: Colors.orangeAccent,
    );
  }
}
