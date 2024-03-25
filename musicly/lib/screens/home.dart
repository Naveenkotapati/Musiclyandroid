
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:musicly/screens/add_song.dart';
import 'package:musicly/screens/album_details.dart';
import 'package:musicly/screens/language_albums.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> allAlbums = [];

  @override
  void initState(){
    setUserRole(userEmail);
    getLanguages();
    getAlbums();
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

  void getLanguages() async{
    final result = await FirebaseFirestore.instance.collection('languages').get();
    if(result.docs.isNotEmpty){
      var resultData = result.docs;
      for(var lang in resultData){
          if(!languages.contains(lang.data()['name'].toString())){
            languages.add(lang.data()['name'].toString());
          }
      }
      setState(() {
        languages;
      });
    }
  }

  void getAlbums() async{
  final result = await FirebaseFirestore.instance.collection('albums').get();
    if(result.docs.isNotEmpty){
      var resultData = result.docs;
      albumsNames = [];
      langAlbums = {};
      for(var album in resultData){
        Map<String, dynamic> albumData = album.data();
        allAlbums.add(albumData);
        albumsNames.add(albumData['name']);
        if(langAlbums.containsKey(albumData['language'])){
          langAlbums[albumData['language']]?.add(albumData);
        }else{
          langAlbums[albumData['language']] = [albumData];
        }
        albumImages[albumData['name']] = albumData['file'];
      }
      setState(() {
        allAlbums;
        albumImages;
        langAlbums;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: 100.0,
            right: 0.0,
            child: buildActionButton(),
          ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buidLangCards(),
              const SizedBox(height: 30,),
              buildAllAlbums(),
              const SizedBox(height: 30,),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: const Text(
                  'Classic',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 4,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              buildClassicAlbums(),
            ],
          ),
        )
      ],
    );
  }

  Widget buildActionButton(){
    if(userRole == 'admin'){
      return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddSongScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: lightColorScheme.primary.withOpacity(0.8)
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Add Song",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            Icon(
              CupertinoIcons.music_note_2,
              color: Colors.white,
              size: 30,
            )
          ],
        ),
      ),
    );
    }
    return Container();
  
  }

  Widget buidLangCards(){
    if(languages.isEmpty){
      return Container();
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(left: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for(String lang in languages)
              buildLandCard(lang),
              const SizedBox(width: 10,)
          ],
        ),
        ),
    );
  }

  Widget buildLandCard(lang){
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        onTap: (){
          if(langAlbums.containsKey(lang)){
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageAlbumsScreen(albumsList: langAlbums[lang]!, lang: lang.toString(),),
                ),
              );
          }else{
            EasyLoading.showError("No Albums Found for This Language $lang");
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: Colors.white.withOpacity(0.5)
          ),
          child: Text(
            lang,
            style: TextStyle(
              color: lightColorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 4
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAllAlbums(){
    if(allAlbums.isEmpty){
      return Container();
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(left: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for( var album in allAlbums)
              buildAlbumCard(album),
              const SizedBox(width: 10,)
          ],
        ),
        ),
    );
  }

  Widget buildClassicAlbums(){
    if(allAlbums.isEmpty){
      return Container();
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(left: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for( var album in allAlbums)
              if(album['genre'].toString().toLowerCase() == 'classic')
                buildAlbumCard(album),
                const SizedBox(width: 10,)
          ],
        ),
        ),
    );

  }

  Widget buildAlbumCard(album){
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumDetailsScreen(album_name: album['name'], album_pic: album['file'],),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                image: DecorationImage(
                  image: NetworkImage(album['file']),
                  fit: BoxFit.cover
                )
              ),
              child: const Text(''),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.white.withOpacity(0.5)
              ),
              child: Text(
                album['name'],
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}