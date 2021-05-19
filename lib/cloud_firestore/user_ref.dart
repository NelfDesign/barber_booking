
import 'package:barber_booking/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<UserModel> getUserProfiles(String phone) async {
  CollectionReference userRef = FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userRef.doc(phone).get();
  if(snapshot.exists){
    var user = UserModel.fromJson(snapshot.data());
    return user;
  }else{
    return UserModel();
  }
}