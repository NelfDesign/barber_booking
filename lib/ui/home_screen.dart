import 'package:barber_booking/cloud_firestore/user_ref.dart';
import 'package:barber_booking/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFDFDFDF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //User profile
            FutureBuilder(
            future: getUserProfiles(FirebaseAuth.instance.currentUser.phoneNumber),
            builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }else {
                  var userModel = snapshot.data as UserModel;
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF383838)
                  ),
                    child: Row(
                        children: [
                          CircleAvatar(
                            child: Icon(Icons.person, color: Colors.white,),
                            backgroundColor: Colors.grey,
                            maxRadius: 30,
                          ),
                          SizedBox(width: 30,),
                          Expanded(
                            child: Column(
                              children: [
                                Text('${userModel.name}',
                                  style: GoogleFonts.robotoMono(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                                Text('${userModel.address}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoMono(
                                      fontSize: 16,
                                      color: Colors.white
                                  ),
                                )
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          )
                        ],
                    ),
                  );
                }
            })
          ],
        ),
      )
    ));
  }
}
