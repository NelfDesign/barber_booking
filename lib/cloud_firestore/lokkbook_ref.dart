import 'package:barber_booking/model/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<ImageModel>> getLookbook() async {
  List<ImageModel> result = new List<ImageModel>.empty(growable: true);
  CollectionReference lookbookRef = FirebaseFirestore.instance.collection('Lookbook');
  QuerySnapshot snapshot = await lookbookRef.get();
  snapshot.docs.forEach((element) {
    result.add(ImageModel.fromJson(element.data()));
  });
  return result;
}