import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:musicly/screens/song_screen.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favSongs = [];

  @override
  void initState() {
    getFavSongsList();
    super.initState();
  }

  void updateUserSongFav(songId, addAdFav) async{
    EasyLoading.show(status: 'adding...');
    if(addAdFav){
      CollectionReference favSong = FirebaseFirestore.instance.collection('favsongs');
      favSong..add({
        'songid': songId,
        'user': userEmail,
      }).then((value) {
        print("Fav Song added");
        setState(() {
          favSongsIds.add(songId);
        });
      }).catchError((error) {
        print("Failed to add  fav album Song : $error");
      });
    }else{
      final result = await FirebaseFirestore.instance.collection('favsongs')
                  .where("songid", isEqualTo: songId)
                  .where("user", isEqualTo: userEmail).get();
      if(result.docs.isNotEmpty){
        String docId = result.docs.first.id;
        await FirebaseFirestore.instance.collection('favsongs').doc(docId).delete();
        favSongsIds.remove(songId);
        setState(() {
          favSongsIds;
        });
      }
    }
    EasyLoading.dismiss();
  }

  void getFavSongsList() async{
    final result = await FirebaseFirestore.instance.collection('favsongs')
                  .where("user", isEqualTo: userEmail).get();
    favSongsIds = [];
    if(result.docs.isNotEmpty){
      var resultData = result.docs;
      favSongs = [];
      for(var album in resultData){
        DocumentSnapshot<Map<String, dynamic>> song = await FirebaseFirestore.instance.collection('songs').doc(album.data()['songid']).get();
        if(song.exists){
          print(2);
          if(song.data()!.isNotEmpty){
            Map<String, dynamic> songData = song.data()!;
            songData['id'] = song.id;
              favSongs.add(songData);
            favSongsIds.add(song.id);
          }
        }
      }
      setState(() {
        favSongs;
        favSongsIds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          for(var song in favSongs)
            buildSongCard(song)
        ],
      ),
    );
  }

  Widget buildSongCard(song){
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.white.withOpacity(0.8)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                 try {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongPlayScreen(songsList: favSongs, currentIndex:favSongs.indexOf(song),),
                    ),
                  );
                } catch (t) {
                    //mp3 unreachable
                    EasyLoading.showError("Unable to play File, $t");
                    print(t);
                }
      
              },
              child: Icon(CupertinoIcons.play_arrow, color: lightColorScheme.primary,),
            ),
            const SizedBox(width: 20,),
            Text(
              "${song['name']} from ${song['album']}",
            ),
            const SizedBox(width: 20,),
            InkWell(
              onTap: (){
                updateUserSongFav(
                  song['id'],
                  !favSongsIds.contains(song['id'])
                );
              },
              child: Icon(favSongsIds.contains(song['id'])?CupertinoIcons.heart_fill:CupertinoIcons.heart, color: lightColorScheme.primary,),
            )
          ],
        ),
      );
  }


}