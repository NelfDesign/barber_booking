import 'package:barber_booking/model/barber_model.dart';
import 'package:barber_booking/model/city_model.dart';
import 'package:barber_booking/model/salon_model.dart';
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

Future<List<SalonModel>> getSalonByCity(String cityName) async {
  List<SalonModel> result = new List<SalonModel>.empty(growable: true);
  CollectionReference salonRef = FirebaseFirestore.instance.collection('AllSalon')
      .doc(cityName.replaceAll(' ', '')).collection("Branch");
  QuerySnapshot snapshot = await salonRef.get();
  snapshot.docs.forEach((element) {
    var salon = SalonModel.fromJson(element.data());
    salon.docId = element.id;
    salon.reference = element.reference;
    result.add(salon);
  });
  return result;
}

Future<List<BarberModel>> getBarberBySalon(SalonModel salon) async {
  List<BarberModel> result = new List<BarberModel>.empty(growable: true);
  CollectionReference barberRef = salon.reference.collection("Barber");
  QuerySnapshot snapshot = await barberRef.get();

  snapshot.docs.forEach((element) {
    var barber = BarberModel.fromJson(element.data());
    barber.docId = element.id;
    barber.reference = element.reference;
    result.add(barber);
  });
  return result;
}

Future<List<int>> getBarberTimeSlot(BarberModel barberModel, String date) async {
  List<int> result = new List<int>.empty(growable: true);
  var bookingRef = barberModel.reference.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();

  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

