import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:musicly/screens/signin_screen.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/loader.dart';
import 'package:musicly/widgets/custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passswordController = TextEditingController();
  bool agreePersonalData = true;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passswordController.dispose();
  }

  @override
  void initState() {
    configLoading();
    super.initState();
  }

  void _submitAuthForm(
    String email,
    String password,
    String userName,
    BuildContext ctx,
  ) async {
    EasyLoading.show(status: "Signing up.....");
    // ignore: unused_local_variable
    UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await FirebaseChatCore.instance.createUserInFirestore(
          types.User(
            firstName: userName,
            id: userCredential.user!.uid, // UID from Firebase Authentication
            imageUrl: 'https://i.pravatar.cc/300',
            lastName: email,
            role: types.Role.user,
          ),
        );
        final roomResult = await FirebaseFirestore.instance
                .collection('rooms').get();
        if(roomResult.docs.isNotEmpty){
          String roomObjId = roomResult.docs.first.id;
          Map<String, dynamic> roomDetails = roomResult.docs.first.data();
          List<String> users=[];
          for(String userid in roomDetails['userIds']){
            users.add(userid);
          }
          users.add(userCredential.user!.uid);
          FirebaseFirestore.instance.collection('rooms').doc(roomObjId)
                            .update({'userIds': users});

        }
      EasyLoading.showSuccess("User created successfully, please login");
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (e) => const SignInScreen(),
        ),
      );
    } on PlatformException catch (err) {
      var message = "An error occured please check your credentails";
      if (err.message != null) {
        message = err.message!;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ));
    } catch (err) {
      // ignore: avoid_print
      print(err);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text("Invalid Credentials, $err"),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ));
    }

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        controller: fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                              color: lightColorScheme.primary,
                            )
                          )
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                              color: lightColorScheme.primary,
                            )
                          )
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // password
                      TextFormField(
                        controller: passswordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                              color: lightColorScheme.primary,
                            )
                          )
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightColorScheme.primary,
                          ),
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Processing Data'),
                                ),
                              );
                             _formSignupKey.currentState!.save();
                             _submitAuthForm(
                                emailController.text, 
                                passswordController.text, 
                                fullNameController.text, 
                                context
                              );
                              emailController.clear();
                              passswordController.clear();
                              fullNameController.clear();
                              _formSignupKey.currentState!.reset();
                            }
                          },
                          child: const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}