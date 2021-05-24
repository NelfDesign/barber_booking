import 'package:barber_booking/model/city_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<CityModel>> getCities() async {
  List<CityModel> result = new List<CityModel>.empty(growable: true);
  CollectionReference cityRef = FirebaseFirestore.instance.collection('AllSalon');
  QuerySnapshot snapshot = await cityRef.get();
  snapshot.docs.forEach((element) {
    result.add(CityModel.fromJson(element.data()));
  });
  return result;
}