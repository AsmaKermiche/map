import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:maps/Wrapper.dart';
import 'package:maps/classes/App.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/servises/auth.dart';
import 'package:maps/servises/firestore.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  String _displayName;
  String _email;
  String _password;
  String _username;
  DateTime _dateOfBirth = DateTime(2001,4,7);
  Gender _gender = Gender.Female;
  ServicesAuth _servicesAuth = ServicesAuth();
  FirestoreService _firestoreService = FirestoreService();
  bool _emailInUse = false ;
  bool _userNameExists = false ;
  bool _autovalidateUsername = false;
  bool _autovalidatePassword = false;
  bool _isHidden = true ;
  final _formKey = GlobalKey<FormState>();
  void _toggleVisibility(){
    setState(() {
      _isHidden = !_isHidden ;
    });
  }
  void _register() async {
    final form = _formKey.currentState;
    Utilisateur utilisateur;
    try {
      _userNameExists = await _firestoreService.userNameExists(_username);
      if (form.validate()) {
        form.save();
        utilisateur = await _servicesAuth.registerEmail(
            _email, _password, _displayName, _username,_dateOfBirth,_gender);
        //Todo remove this
        App app = App(utilisateur);
        app.test();
        print('Test completed');

        Provider.of<User>(context, listen: false).setUtilisateur(utilisateur);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Groups()) );
      }
    }
    catch (e) {
        print(e.code);
        switch (e.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            {
              print('EMAIL_ALREADY_IN_USE');
              _emailInUse = true ;
              form.validate();
              _emailInUse = false ;
            }
            break;
          default:
            {
              print('UKNOWN_ERROR');
              //TODO : show something saying something went wrong and qsking the user to check his internet connection
            }
        }
        return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/signup.jpg'), fit: BoxFit.cover)),

            ///////////////////////////////////////////////////////////////////////
            //  height: double.infinity,
            // width: double.infinity,
            // decoration: BoxDecoration(
            // gradient: LinearGradient(
            // begin: Alignment.topCenter,
            // end: Alignment.bottomCenter,
            // colors: [
            //  Color(0xFF73AEF5),
            // Color(0xFF61A4F6),
            //   Color(0xFF478DE0),
            //  Color(0xFF398AE5)
            //],
            //  stops: [
            // 0.1,
            //  0.4,
            //  0.7,
            //    0.9
            //    ]),
            //),
            /////////////////////////////////////////////////////////////////
          ),

          Container(
            alignment: Alignment.center,
            height: 650.00,
            width: 382.0,
            decoration: BoxDecoration(
                color: Color(0xffF2E9DB).withAlpha(100),
                boxShadow: [BoxShadow(
                  offset: Offset(24.00, 24.00),
                  color: Color(0xffF2E9DB).withAlpha(40),
                  blurRadius: 42,
                ),],
                borderRadius: BorderRadius.circular(50.00)
            ),
            child : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'REBIENVENUE !',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          shadows: [
                            Shadow(
                                offset: Offset(0.00, 3.00),
                                blurRadius: 6,
                                color: Color(0xffE8652D))
                          ],
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 25.0,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0)),
                          height: 60.0,
                          child: TextFormField(
                            validator: (val) => val.isEmpty ? 'Saisissez votre nom s\'il vous plait' : null ,
                            onSaved: (val) => this._displayName = val,
                            cursorColor: Color(0xff739D84),
                            style: TextStyle(color: Color(0xff739D84)),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14.0),
                              prefixIcon: Icon(
                                Icons.sentiment_satisfied,
                                color: Color(0xff739D84),
                              ),
                              hintText: "Saisissez votre nom complet",
                              hintStyle: TextStyle(color: Color(0xff739D84)),
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 25.0,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0)),
                          height: 60.0,
                          child: TextFormField(
                            validator : (val) {
                                if (val.isEmpty)
                                  return 'Saisissez votre nom d\'utilisateur s\'il vous plait' ;
                                else if (_userNameExists){
                                  return 'Username already exists please enter a diffrent one';
                                }
                                else
                                  return null;
                            },
                            autovalidate: _autovalidateUsername,
                            onChanged : (val) async {
                              _username = val;
                              setState(() {
                                _autovalidateUsername = true ;
                              });
                              if(val.isNotEmpty){
                                try{
                                  bool b = await _firestoreService.userNameExists(val);
                                  setState(() {
                                    _userNameExists = b;
                                  });
                                }
                                catch(e){
                                  print(e);
                                  //TODO : show something saying something went wrong and qsking the user to check his internet connection
                                }
                              }
                            },
                            onSaved: (val) => this._username = val,
                            cursorColor: Color(0xff739D84),
                            style: TextStyle(color: Color(0xff739D84)),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14.0),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xff739D84),
                              ),
                              hintText: "Saisissez votre nom d'utilisateur",
                              hintStyle: TextStyle(color: Color(0xff739D84)),
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 25.0,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0)),
                          height: 60.0,
                          child: TextFormField(
                            validator : (val)  {
                              if (val.isEmpty)
                                return 'Saisissez votre email s\'il vous plait' ;
                              else if (!EmailValidator.validate(val, true))
                                return 'Cet email n\'est pas valide' ;
                              else if (this._emailInUse)
                                return 'Email already in use please sign in or enter a diffrent email ';
                              else
                                return  null;
                            },
                            onSaved: (val)=>this._email = val,
                            cursorColor: Color(0xff739D84),
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Color(0xff739D84)),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14.0),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xff739D84),
                              ),
                              hintText: "Entrez votre adresse mail",
                              hintStyle: TextStyle(color: Color(0xff739D84)),
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 25.0,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0)),
                          height: 60.0,
                          child: TextFormField(
                            validator: (val) {
                              if (val.isEmpty)
                                return 'Saisisser votre mot de passe s\'il vous plait';
                              else if (val.length < 6)
                                return 'Votre mot de passe doit contenir aumoin 6 caractères';
                              else
                                return null;
                            },
                            onSaved: (val) => this._password = val,
                            autovalidate: _autovalidatePassword,
                            onChanged: (val)=> setState(() {
                              _autovalidatePassword = true ;
                            }),
                            obscureText: _isHidden ,
                            cursorColor: Color(0xff739D84),
                            style: TextStyle(color: Color(0xff739D84)),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14.0),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color(0xff739D84),
                              ),
                              suffixIcon:  IconButton(
                                  icon: _isHidden? Icon(Icons.visibility_off ,color: Color(0xff739D84) ) : Icon(Icons.visibility , color: Color(0xff739D84)),
                                  onPressed: _toggleVisibility),
                              hintText: "Créez votre mot de passe",
                              hintStyle: TextStyle(color: Color(0xff739D84)),
                            ),

                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Votre mot de passe doit contenir aumoin 6 caractères.",
                              style:
                              TextStyle(fontSize: 11.00, color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          width: 250.0,
                          child: RaisedButton(
                            elevation: 5.0,
                            onPressed: () => _register(),
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            color: Color(0xffF1B97A),
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                  color: Color(0xffE8652D),
                                  letterSpacing: 1.5,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
