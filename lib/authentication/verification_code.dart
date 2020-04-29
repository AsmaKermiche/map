import 'package:flutter/material.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/servises/auth.dart';

class Verify extends StatefulWidget {

  @override
  _VerifyState createState() => new _VerifyState();
}

class _VerifyState extends State<Verify> {
  String _phoneNumber = '+213 676370021';
  Utilisateur _utilisateur = Utilisateur('yadi', 'hello', 'hello',Gender.Female,DateTime(2001,4,7)) ;
  List<String>_digits = List<String>(6);
  String _smsCode;
  final _formKey = GlobalKey<FormState>();
  ServicesAuth _servicesAuth = ServicesAuth();
  List<TextEditingController> controllers = <TextEditingController>[
    new TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  void _sendCode (){
    try {
      _servicesAuth.sendVerificationCode(_phoneNumber);
    }
    catch (e){
      print(e);
    }
  }
  void _verify () async {
    _smsCode = concatinate();
    print (concatinate());
    print(_smsCode);
    try{
      await _servicesAuth.linkPhoneNumber(_phoneNumber, _utilisateur, _smsCode).then((_)=>print('---done---'))
          .catchError( (error){
        print(error.code);
        switch(error.code){
          case 'ERROR_INVALID_VERIFICATION_CODE' :
            print('ERROR_INVALID_VERIFICATION_CODE');
            break ;
          case '' :
            print('ERROR_SESSION_EXPIRED');
            break ;
          default :
            break ;
        }
      });
    }
    catch(error){
      switch(error.code){
        case 'ERROR_INVALID_VERIFICATION_CODE' :
              print('ERROR_INVALID_VERIFICATION_CODE');
          break ;
        case '' :
          print('ERROR_SESSION_EXPIRED');
          break ;
        default :
          break ;
      }
      print(error.code);
    }
  }
  @override
  void initState() {
    super.initState();
    int i;
    for (i=0;i<6;i++){
      _digits[i] ='-';
    }
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xff739D84),
        body: Container(
            height: double.infinity,
            child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 30.0,
                ),
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset("assets/images/texto.png"),
                          SizedBox(
                            height: 30.0,
                          ),
                          new Text("Entrez le code qui a été envoyer au numéro \n$_phoneNumber", textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                          SizedBox(height: 40,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: pinBoxs(50.0, controllers, Color(0xfff2e9db), Color(0xffe8652d), context, false),
                          ),
                          SizedBox(height: 60,),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            width: 250,
                            child: RaisedButton(
                              elevation: 5.0,
                              onPressed: () => _verify (),
                              padding: EdgeInsets.all(15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              color: Color(0xFFF1B97A),
                              child: Text(
                                'VERIFIER',
                                style: TextStyle(
                                  color: Color(0xFFE8652D),
                                  letterSpacing: 1.5,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          FlatButton(
                            child:
                            Text("Renvoyer le code ",
                              style: TextStyle(
                                color:Color(0xFFF1B97A),
                              ),
                            ),
                            onPressed: () => _sendCode () ,
                          ),

                        ]
                    )
                ),
            )
        )
    );
  }
  //---------------------------------Pinbox methodes------------------------------------------
  InputDecoration inputFormat(Color fillColor){
    return new InputDecoration(
      fillColor: fillColor,
      filled: true,
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(12.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
    );
  }

  TextStyle textStyle(double fontSize, Color color, FontWeight fontWeight){
    return new TextStyle(
        color: color,
        decoration: TextDecoration.none,
        fontSize: fontSize,
        fontWeight: fontWeight
    );
  }

  Container pinBox(double width, TextEditingController con, FocusNode focusNode,
      FocusNode nextFocusNode, Color boxColor, Color textColor, BuildContext context, bool show,int pos) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      width: 45.00,
      child: new TextField(
        decoration: inputFormat(boxColor),
        controller: con,
        textAlign: TextAlign.center,
        cursorColor: boxColor,
        maxLines: 1,
        onChanged: (text) {
          if (text.length > 1) {
            con.text = text.substring(text.length - 1);
          }
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
          _digits[pos] = con.text;
        },
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        autofocus: false,
        style: textStyle(30.0, textColor, FontWeight.bold),
      ),
    );
  }

  List<Widget> pinBoxs(double width, List<TextEditingController> cons,
      Color boxColor, Color textColor, BuildContext context, bool show) {
    List<Widget> boxs = new List();
    List<FocusNode> focusNodes = new List();
    focusNodes.add(new FocusNode());
    for(int i = 0; i < cons.length ; i++){
      focusNodes.add(new FocusNode());
      if(i == cons.length - 1){
        focusNodes[i+1] = null;
      }
      boxs.add(pinBox(width, cons[i], focusNodes[i], focusNodes[i+1], boxColor, textColor,context, show,i));
    }
    return boxs;
  }
//Concatinate six digits
  String concatinate ( ){
    String smsCode ='';
      int i;
      for(i=0;i<6;i++){
        smsCode = smsCode + _digits[i];
      }
      return smsCode;
  }
}
