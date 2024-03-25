import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:musicly/screens/song_screen.dart';
import 'package:musicly/theme/theme.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:musicly/utils/constants.dart';

class AlbumDetailsScreen extends StatefulWidget {
  const AlbumDetailsScreen(
      {super.key, required this.album_name, required this.album_pic});

  final String album_name;
  final String album_pic;
  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  List<Map<String, dynamic>> albumSongs = [];
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    getAlbumSongs();
    super.initState();
  }

  void updateUserSongFav(songId, addAdFav) async {
    EasyLoading.show(status: 'adding...');
    if (addAdFav) {
      CollectionReference favSong =
          FirebaseFirestore.instance.collection('favsongs');
      favSong
        ..add({
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
    } else {
      final result = await FirebaseFirestore.instance
          .collection('favsongs')
          .where("songid", isEqualTo: songId)
          .where("user", isEqualTo: userEmail)
          .get();
      if (result.docs.isNotEmpty) {
        String docId = result.docs.first.id;
        await FirebaseFirestore.instance
            .collection('favsongs')
            .doc(docId)
            .delete();
        favSongsIds.remove(songId);
        setState(() {
          favSongsIds;
        });
      }
    }
    EasyLoading.dismiss();
  }

  void getAlbumSongs() async {
    final result = await FirebaseFirestore.instance
        .collection('songs')
        .where("album", isEqualTo: widget.album_name)
        .get();
    if (result.docs.isNotEmpty) {
      var resultData = result.docs;
      albumSongs = [];
      for (var albumsong in resultData) {
        Map<String, dynamic> songData = albumsong.data();
        songData['id'] = albumsong.id;
        albumSongs.add(songData);
      }
      setState(() {
        albumSongs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.album_name,
          style: const TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: lightColorScheme.primary,
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg2.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: buildAlbumSongs(),
        ),
      ),
    );
  }

  Widget buildAlbumSongs() {
    if (albumSongs.isEmpty) {
      return Center(
        child: Text("${widget.album_name}, has no songs"),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          buildALbumBanner(),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: buildSongsList(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildALbumBanner() {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          image: DecorationImage(
              image: NetworkImage(widget.album_pic), fit: BoxFit.cover)),
      child: Text(widget.album_name.toUpperCase()),
    );
  }

  Widget buildSongsList() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: lightColorScheme.primary),
      child: Column(
        children: [for (var song in albumSongs) buildSongCard(song)],
      ),
    );
  }

  Widget buildSongCard(song) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.white.withOpacity(0.8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayScreen(
                      songsList: albumSongs,
                      currentIndex: albumSongs.indexOf(song),
                    ),
                  ),
                );
              } catch (t) {
                //mp3 unreachable
                EasyLoading.showError("Unable to play File, $t");
                print(t);
              }
            },
            child: Icon(
              CupertinoIcons.play_arrow,
              color: lightColorScheme.primary,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                "${song['name']} from ${widget.album_name}",
              )),
          const SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: () {
              updateUserSongFav(song['id'], !favSongsIds.contains(song['id']));
            },
            child: Icon(
              favSongsIds.contains(song['id'])
                  ? CupertinoIcons.heart_fill
                  : CupertinoIcons.heart,
              color: lightColorScheme.primary,
            ),
          )
        ],
      ),
    );
  }
}
