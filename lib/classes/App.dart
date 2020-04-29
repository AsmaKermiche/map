import 'package:maps/classes/Groupe.dart';
import 'package:maps/classes/Request.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:maps/classes/Utilisateur.dart';
import 'package:maps/classes/transport.dart';
import 'package:maps/servises/firestore.dart';
import 'package:maps/servises/auth.dart';

class App {
  final FirestoreService _firestoreService = FirestoreService ();
  final ServicesAuth _servicesAuth = ServicesAuth();
  Utilisateur _utilisateur ; //utilisateur connecté à l'application
  List<Utilisateur> _list_utilisateur ;
  List<Group> _list_groupes;

  App (Utilisateur utilisateur){
    _utilisateur = utilisateur;
  }

  void test () async
  {
    try {
      //u.setDateOfBirth();
      /*_utilisateur.setDisplayName('Yasmina');
      _utilisateur.setPhone('+213 676370021');
      _utilisateur.removePhone();
      _utilisateur.setPhone('phone');
      _utilisateur.changeActiveStatus();
      _utilisateur.setPhoto();
      _utilisateur.deletePhoto();
      _utilisateur.setTransport(Transport.Voiture);
      _utilisateur.addVehicule(new Vehicle('matricule', 'model', 'color'));
      _utilisateur.setLocation();*/
      ajouterGroupe('groupe1', List<String>());
      ajouterGroupe('groupe2', List<String>());
      ajouterGroupe('groupe3', List<String>());
      ajouterGroupe('groupe4', List<String>());

    }
    catch (e){

    }
  }

  void ajouterGroupe (String nom,List<String> membres) async {
    if(_utilisateur!=null){
      Group groupe = await _firestoreService.createGroupDoc(nom, this._utilisateur.sharableUserInfo.id,membres);
      //TODO remove this :
      groupe.addMember('amembersUID');
      this._utilisateur.addGroupe(groupe.gid);
      membres.forEach((member){
        addMemberToGroup(groupe, member);
      });
    }
    else {
        print('No user signned in or up \n This should\'nt happen ?!!');
    }
  }
  void addMemberToGroup (Group groupe,String member){
    if(_utilisateur!=null){
      String text = this._utilisateur.sharableUserInfo.displayName+' invites you to join the groupe '+groupe.nom;
      _firestoreService.sendInvitationFromGroup(member,_utilisateur.sharableUserInfo.id, groupe.gid,text);
    }
    else {
      print('Could\'nt send request : No user : this shouldn=\'t happen');
    }
  }
  void joinGroupe (String groupeID){
    if(_utilisateur!=null){
      String text = this._utilisateur.sharableUserInfo.displayName+' asks join this groupe';
      _firestoreService.sendInvitationFromUser(groupeID, this._utilisateur.sharableUserInfo.id, groupeID, text);
    }
    else {
      print('No user signned in or up \n This should\'nt happen ?!!');
    }
  }

  void refuseInvitation (Request request){
    request.setAccepted(false);
  }
  void acceptInvitation (Request request){
    request.setAccepted(true);
  }
}