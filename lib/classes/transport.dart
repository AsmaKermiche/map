class Vehicle
{
  String matricule;
  String model;
  String color;
  Vehicle(String matricule,String model,String color)
  {
    this.matricule = matricule;
    this.model = model;
    this.color = color;
  }
  Vehicle.fromMap (Map<String,dynamic> data){
    matricule = data['Matricule'];
    model = data['Model'];
    color = data['Color'];
  }
  Map<String,dynamic> vehicleToMap(){
    return {
      'Matricule': this.matricule,
      'Model': this.model,
      'Color': this.color,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Vehicle &&
              runtimeType == other.runtimeType &&
              matricule == other.matricule;

  @override
  int get hashCode => matricule.hashCode;
}

enum Transport
{
  Voiture,Moto,Train,Bus,Bicyclette, Apieds , Autres,
}