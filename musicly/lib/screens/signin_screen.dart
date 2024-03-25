import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:musicly/screens/nav.dart';
import 'package:musicly/screens/signup_screen.dart';
import 'package:musicly/utils/constants.dart';
import 'package:musicly/utils/loader.dart';
import 'package:musicly/widgets/custom_scaffold.dart';

import '../theme/theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    configLoading();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _submitAuthForm(
    String email,
    String password,
    BuildContext ctx,
  ) async {
    EasyLoading.show(status: "Logging In..");
    // ignore: unused_local_variable
    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final result = await FirebaseFirestore.instance
                .collection('users')
                .where("lastName", isEqualTo: email)
                .get();
      if(result.docs.isNotEmpty){
        var resultData = result.docs.first.data();
        if(resultData.isNotEmpty){
          userRole = resultData['role'];
          setState(() {
            userRole = resultData['role'];
          });
        }
      }
      setState(() {
        userEmail = email;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const NavScreen()));
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
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
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
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
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
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightColorScheme.primary,
                          ),
                          onPressed: () {
                            if (_formSignInKey.currentState!.validate() &&
                                rememberPassword) {
                             _formSignInKey.currentState!.save();
                             _submitAuthForm(
                                emailController.text, 
                                passwordController.text, 
                                context
                              );
                              emailController.clear();
                              passwordController.clear();
                              _formSignInKey.currentState!.reset();
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
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