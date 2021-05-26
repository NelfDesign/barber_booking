import 'package:barber_booking/state/state_management.dart';
import 'package:barber_booking/ui/booking_screen.dart';
import 'package:barber_booking/ui/home_screen.dart';
import 'package:barber_booking/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //Firebase
  Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings){
        switch(settings.name){
          case '/home':
            return PageTransition(
                child: HomePage(),
                settings: settings,
                type: PageTransitionType.fade);
            break;
          case '/booking':
            return PageTransition(
                child: BookingScreen(),
                settings: settings,
                type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/my_bg.png"),
              fit: BoxFit.cover
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             Container(
               padding: const EdgeInsets.all(16),
               width: MediaQuery.of(context).size.width,
               child: FutureBuilder(
                 future: checkLoginState(context, false, scaffoldState),
                 builder: (context, snapshot){
                   if(snapshot.connectionState == ConnectionState.waiting){
                     return Center(child: CircularProgressIndicator());
                   }else{
                     var userState = snapshot.data as LOGIN_STATE;
                     if(userState == LOGIN_STATE.LOGGED){
                        return Container();
                     } else {// if user not login before then return button
                       return ElevatedButton.icon(
                           icon: Icon(Icons.phone, color: Colors.white,),
                           label: Text("Login with phone",style: TextStyle(
                               color: Colors.white
                           ),),
                           style: ButtonStyle(
                             backgroundColor: MaterialStateProperty.all(Colors.black),
                           ),
                           onPressed: () => processLogin(context)
                       );
                     }
                   }
                 },
               ),
             )
            ],
          ),
        )
      ),
    );
  }

  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    print('user = $user');
    if(user == null){
      FirebaseAuthUi.instance().launchAuth([
        AuthProvider.phone()
      ]).then((fireBaseUser) async{
        //refresh state
        print('user = $fireBaseUser');
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        //start new screen
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e){
        if(e is PlatformException){
          if(e.code == FirebaseAuthUi.kUserCancelledError){
            ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
                SnackBar(content: Text("${e.message}")));
          }else{
            ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
                SnackBar(content: Text("Unk error")));
          }
        }
      });
    }else{

    }
  }

 Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin, GlobalKey<ScaffoldState> scaffoldState) async{
    if(!context.read(forceReload).state){
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3)).then((value){
        FirebaseAuth.instance.currentUser
            .getIdToken()
            .then((token) async {
          print('token = $token');
          context.read(userToken).state = token;
          //Check user in Firestore
          CollectionReference userRef = FirebaseFirestore.instance.collection('User');
          DocumentSnapshot snapshotUser = await userRef
              .doc(FirebaseAuth.instance.currentUser.phoneNumber)
              .get();
          //force reload state
          context.read(forceReload).state = true;
          if(snapshotUser.exists){
            Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
          }else{
            // if user info doesn't available, show alert
            var nameController = TextEditingController();
            var adressController = TextEditingController();
            Alert(
                context: context,
                title: 'Update Profile',
                content: Column(
                  children: [
                    TextField(decoration: InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Name'
                    ),controller: nameController,),
                    TextField(decoration: InputDecoration(
                        icon: Icon(Icons.home),
                        labelText: 'Address'
                    ),controller: adressController,),
                  ],
                ),
                buttons: [
                  DialogButton(child: Text('CANCEL'), onPressed: ()=> Navigator.pop(context)),
                  DialogButton(child: Text('UPDATE'), onPressed: (){
                    //update user
                    userRef.doc(FirebaseAuth.instance.currentUser.phoneNumber)
                        .set({
                      'name': nameController.text,
                      'address': adressController.text
                    }).then((value) async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
                          SnackBar(content: Text('Update profil successfully!!'))
                      );
                      await Future.delayed(Duration(seconds: 1), (){
                        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                      });
                    }).catchError((e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
                          SnackBar(content: Text('$e'))
                      );
                    });
                  }),
                ]
            ).show();
          }
        });
      });
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }
}


