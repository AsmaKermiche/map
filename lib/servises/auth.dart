import 'dart:convert';
import 'dart:io';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:maps/classes/Groupe.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/servises/firestore.dart';

class ServicesAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  //List of user's authenticated in this app
  UsersCredentials _usersCredentials = UsersCredentials();
  //Attributes used in phone authenticaion :
  String _verificationID;
  String _smsCode;
  List<int> _forceResendingToken;

  bool isSignedIn(){
    return (_firebaseAuth.currentUser()!=null);
  }
   Future<String> userID () async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return firebaseUser.uid;
  }

  //--------------------------------Authentication-----------------------------------------
  Future<Utilisateur> signInEmail(String email, String password) async
  {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password); //Sign in with email and password
      FirebaseUser user = result.user; // Put the result in a objectwith the type : FirebaseUser
      String uid = user.uid;
       // Get user's info in an object Utilisateur
      SharableUserInfo userInfo = await _firestoreService.getUserInfo(uid);
      return Utilisateur.old(uid, userInfo);
  }

  Future<Utilisateur> registerEmail(String email, String password, String displayName,String username,DateTime dateOfBirth,Gender gender) async {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password); //Create new user
      FirebaseUser user = result.user;
      await user.sendEmailVerification().then((_){
        print('A verification email has been sent');
      }).catchError((error){
        print('something went wrong when sending the verification email'+error.code);
      });
      String uid = user.uid;
      Utilisateur utilisateur =  uid != null
          ? Utilisateur(uid, displayName, username, gender, dateOfBirth)
          : null;
      if(utilisateur!=null)
        {
          await _firestoreService.createUserDoc(utilisateur)
              .then((_){
            print('A user doc has been created');
          });
      }
      return utilisateur ;//Return an 'Utilisateur' object
  }

  Future<Utilisateur> signInGoogle (){


  }
  Future<Utilisateur> signInFacebook (){


  }


  //-------------------------Changing user's email-----------------------------------------------
  Future<void> changeEmail(String password ,String newEmail) async
  {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if(user!=null){
      await reauthenticateUserEmail(password).then((_){
        //Pass in the password to updatePassword.
        user.updateEmail(user.email).then((_){
          print('email changed');
        }).catchError((error){
          print('clould\'nt update email'+error.code);
        });
      }).catchError((error){
        print('Could\'nt authenticate user');
      });
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  //-------------------------Changing user's password-----------------------------------------------
  Future<void>changePassword(String currentPassword,String newPassword) async
  {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if(user!=null){
      await reauthenticateUserEmail(currentPassword).then((_){
        //Pass in the password to updatePassword.
        user.updatePassword(newPassword).then((_){
          print('password changed');
        }).catchError((error){
          print(error.code);
        });
      }).catchError((error){
        print('Could\'nt authenticate user');
      });
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  //-------------------------Resetting user's password-----------------------------------------------
  Future<void> resetPasswordEmail(String email)async {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((_){
        print('A reset link has been sent to this email please check your email and sign in again');
      }).catchError((error){
        print('cloudn\'t send reset linl'+error.code);
      });
  }
  //----------------------------Phone relates methods-----------------------------------------------
  //Sending a verification code to the the provided phone number
  void sendVerificationCode(String phone) async {
    //_auth.setLanguageCode('fr');
    if(phone!=null)
      await _firebaseAuth.verifyPhoneNumber(phoneNumber: phone, timeout: Duration(seconds: 60), verificationCompleted: _verificationCompleted,
          verificationFailed: _verificationFailed, codeSent: _codeSent, codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout);
  }
  //***************************Functions needed********************************
  //Auto-retrieval (detect SMS) / instant verification (no send/retrieve)
  void _verificationCompleted(AuthCredential credential) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if(user!=null){
      user.linkWithCredential(credential).then((_){
        print('phone number added');
      }).catchError((error){
        print('couldn\'t add phone number (at linking with credentials)'+error.code);
      });
    }
  }
  //Couldn't send SMS or Invalid Code
  void _verificationFailed(AuthException authException) async {
    print('verification failed'+authException.code);
    //TODO verify this :
    switch (authException.code) {
      case "INVALID_CREDENTIALS":
        {
          print('INVALID_CREDENTIALS');
        }
        break;
      case "TOO_MANY_REQUESTS":
        {
          print('TOO_MANY_REQUESTS');
        }
        break;
      default:
        {
          print('UKNOWN_ERROR');
        }
        break;
    }
  }

  void _codeSent (String verificationId, [code]){
    print('please enter the code that has been sent to you');
    this._verificationID = verificationId;
    this._forceResendingToken = code;
  }
  //Called after the timeout duration specified
  void _codeAutoRetrievalTimeout(String verificationId){
    this._smsCode = verificationId;
    //print('The verification code that has been set is now invalid, please add your phone number again');
  }
  //***************************************************************************
  //Adding a phone number  (send verification email beforr using this method)
  Future<void> linkPhoneNumber (String phone,Utilisateur u,String smsCode) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if(user==null)
      print ('user == null');
    if ((user!=null) &&(u!=null)&&(this._verificationID!=null)&& (smsCode!=null)){
      this._smsCode = smsCode;
      //Creating  a PhoneAuthCredential object
      AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: this._smsCode);
      u.setPhone(phone);
      user.linkWithCredential(credential);
    }
    else
      print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
  }
  //If the user forgets his password (send verification email beforr using this method)
  Future<void> signInPhone(String smsCode)async {
    //TODO maybe we don\'t need this
    this._smsCode = smsCode;
    //Creating  a PhoneAuthCredential object
    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: this._smsCode);
    _firebaseAuth.signInWithCredential(credential)
        .then((onValue){
          print('Signned In with phone');
    })
        .catchError((error){
          print('Couldn\'t sign in with phone');
    });
  }
  //Removing a phone number
  void removePhoneNumber () async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.unlinkFromProvider(PhoneAuthProvider.providerId);
  }


  //-------------------------Re-authenticating user-----------------------------------------------
  Future<void> reauthenticateUserEmail (String password ) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if (user!=null){
      AuthCredential credential = EmailAuthProvider.getCredential(email: user.email ,password: password);
      user.reauthenticateWithCredential(credential).then((authResult){
        //AuthResult a = authResult;
        print('User reauthenticated');
      }).catchError((){
        print('clouldn\'t reauthrnticate user');
      });
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  Future<void> reauthenticateUserPhone (String smsCode) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if (user!=null){
      AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: smsCode);
      user.reauthenticateWithCredential(credential).then((authResult){
        //AuthResult a = authResult;
        print('User reauthenticated');
      }).catchError((){
        print('clouldn\'t reauthrnticate user');
      });
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  //----------------------------------------Remebred users--------------------------------------------------------
  String getUsersPassword (String email){
    if (_usersCredentials.emailsIsSaved(email)){
      return _usersCredentials.passwordOf(email);
    }
    else
      return null;
  }
  List<String> getUsers (Pattern pattern){
    List<String> suggestions = new List<String>() ;
    _usersCredentials.rememberedUsers().forEach((email){
      if(email.startsWith(pattern)){
        suggestions.add(email);
      }
    });
    if (suggestions.isNotEmpty)
      return suggestions;
    else
      return null;
  }
  Future<void> saveUsersCredential (String email,String password) async {
    File myUsersCredentials;
    Directory myDirectory;
    String fileName = 'usersCredentials.json';
    bool fileExists  = false ;
    /* Getting/Creating my file */
    await getApplicationDocumentsDirectory().then((Directory directory) {
      myDirectory = directory;
      myUsersCredentials = new File(myDirectory.path + '/' + fileName);

      if(!fileExists){
        myUsersCredentials.createSync();
        fileExists = true;
      }
      _usersCredentials.addCredentials(email, password);
      String encodedUsersCredentials = jsonEncode(_usersCredentials);
      myUsersCredentials.writeAsStringSync(encodedUsersCredentials);
    });
  }
  Future<void> getUsersCredentials () async {
    File myUsersCredentials;
    Directory myDirectory;
    String fileName = 'usersCredentials.json';
    bool fileExists  = false ;
    UsersCredentials usersCredentials;
    /* Getting/Creating my file */
    myDirectory =  await getApplicationDocumentsDirectory();
    myUsersCredentials = new File(myDirectory.path+ "/" + fileName);
    fileExists = myUsersCredentials.existsSync();
    if(!fileExists){
      usersCredentials = UsersCredentials ();
    }
    else {
      String encodedUsersCredentials = myUsersCredentials.readAsStringSync();
      usersCredentials = UsersCredentials.fromJson(jsonDecode(encodedUsersCredentials));
    }
    _usersCredentials = usersCredentials;
  }
  //-------------------------------Sign out-----------------------------------------
  void signOut (){
    _firebaseAuth.signOut();
  }
}

class UsersCredentials {
  Map<String,String> _usersCredentials;

  UsersCredentials (){
    _usersCredentials = new Map<String,String>();

  }
  UsersCredentials.fromJson (Map<String, dynamic> json){
    _usersCredentials = new Map<String,String>();
    json.forEach((key,value){
        _usersCredentials.putIfAbsent(key, ()=>value);
    });
  }
  Map<String,dynamic> toJson() => _usersCredentials;

  void addCredentials (String email,String password){
    if(!_usersCredentials.containsKey(email)){
      _usersCredentials.putIfAbsent(email , ()=> password);
    }
  }
  String passwordOf(String email) {
    return _usersCredentials[email];
  }
  List<String> rememberedUsers (){
    return new List.from(_usersCredentials.keys);
  }
  bool emailsIsSaved (String email){
    return _usersCredentials.containsKey(email);
  }
}