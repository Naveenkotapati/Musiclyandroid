import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicly/screens/community_chat.dart';
import 'package:musicly/screens/events.dart';
import 'package:musicly/screens/fav.dart';
import 'package:musicly/screens/home.dart';
import 'package:musicly/screens/welcome_screen.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

enum _SelectedTab { home, favorite, search, person }

class _NavScreenState extends State<NavScreen> {

  var _selectedTab = _SelectedTab.home;
  final List<Widget> _listOfWidget=[
    const HomeScreen(), const FavoriteScreen(), const EventsScreen(), const CommunitChat()
  ];
  late PageController _pageController;
  int selectedIndex = 0;

  @override
  void initState(){
    _pageController = PageController(initialPage: selectedIndex);
    setUserRole(userEmail);
    super.initState();
  }

  void setUserRole(email) async{
    final result = await FirebaseFirestore.instance
                .collection('users')
                .where("lastName", isEqualTo: email)
                .get();
    if(result.docs.isNotEmpty){
      var resultData = result.docs.first.data();
      if(resultData.isNotEmpty){
          userRole = resultData['role'];
          setState(() {
            userRole;
          });
      }
    }
  }

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });
    setState(() {
      selectedIndex = i;
    });
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
  }

  void logout() async{
    setState(() {
      userRole='user';
    });
    await FirebaseAuth.instance.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.jpeg"),
            fit: BoxFit.cover,
          )
        ),
      
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                      'Musicly',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontSize: 30,
                        color: Colors.white
                      ),
                      textAlign: TextAlign.left,
                      ),
                      InkWell(
                        onTap: () {
                         logout();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.white.withOpacity(0.6)
                          ),
                          child: const Icon(
                            CupertinoIcons.arrow_left_circle_fill,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: _listOfWidget,
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar:  DotNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.7),
          marginR: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
          paddingR: const EdgeInsets.only(bottom: 5, top: 5),
          currentIndex: _SelectedTab.values.indexOf(_selectedTab),
          onTap: _handleIndexChanged,
          // dotIndicatorColor: Colors.black,
          items: [
            DotNavigationBarItem(
              icon: const Icon(Icons.home),
              selectedColor: lightColorScheme.primary,
            ),
            DotNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              selectedColor: lightColorScheme.primary,
            ),
            DotNavigationBarItem(
              icon: const Icon(Icons.event_note),
              selectedColor: lightColorScheme.primary,
            ),
            DotNavigationBarItem(
              icon: const Icon(CupertinoIcons.chat_bubble_2),
              selectedColor: lightColorScheme.primary,
            ),
          ],
        ),
    );
  }
}