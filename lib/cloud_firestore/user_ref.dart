
import 'package:barber_booking/model/user_model.dart';
import 'package:barber_booking/state/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<UserModel> getUserProfiles(BuildContext context, String phone) async {
  CollectionReference userRef = FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userRef.doc(phone).get();
  if(snapshot.exists){
    var user = UserModel.fromJson(snapshot.data());
    context.read(userInformation).state = user;
    return user;
  }else{
    return UserModel();
  }
}