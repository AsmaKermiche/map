import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps/servises/firestore.dart';

class TimePlace implements Comparable <TimePlace>{
  GeoPoint _location;
  DateTime _date;
  final FirestoreService _firestoreService = FirestoreService();
  //Constructor
  TimePlace (GeoPoint position,DateTime dateTime){
    this._location = position;
    this._date = dateTime;
  }
  TimePlace.fromMap (Map<String,dynamic> data){
      this._location = data['Location'];
      Timestamp date = data['Date'];
      this._date = date.toDate();
  }
  Map<String,dynamic> TimePlaceToMAp (){
    return {
      'Location' : location,
      'Date' : _firestoreService.firestoreDateTime(this._date),
    };
  }
  //Getters
  DateTime get date => _date;

  GeoPoint get location => _location;

  @override
  int compareTo(TimePlace other) {
    return this._date.compareTo(other.date);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimePlace &&
              runtimeType == other.runtimeType &&
              _date == other._date;

  @override
  int get hashCode => _date.hashCode;
}