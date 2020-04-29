import 'package:flutter/material.dart';
import 'package:maps/classes/App.dart';

class Inscription extends StatefulWidget {
  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  App app ;

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        title: Text('sign up with email and password'),
      ),
      body: Container(
        child : RaisedButton(
            child: Text('Sign up'),
            onPressed: () async {
              app.test();
            }
        ),
      ),

    );
  }
}
