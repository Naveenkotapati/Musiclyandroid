import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:musicly/screens/nav.dart';
import 'package:musicly/screens/welcome_screen.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

void setUserRole(email) async {
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where("lastName", isEqualTo: email)
      .get();
  if (result.docs.isNotEmpty) {
    var resultData = result.docs.first.data();
    if (resultData.isNotEmpty) {
      userRole = resultData['role'];
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musicly',
      theme: lightMode,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            userEmail = userSnapshot.data!.email.toString();
            setUserRole(userEmail);
            return const NavScreen();
          }
          return const WelcomeScreen();
        },
      ),
      builder: EasyLoading.init(),
    );
  }
}
