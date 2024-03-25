import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';

class SongPlayScreen extends StatefulWidget {
  SongPlayScreen({
    Key? key,
    required this.songsList,
    required this.currentIndex,
  }) : super(key: key);

  final List<Map<String, dynamic>> songsList;
  int currentIndex;

  @override
  State<SongPlayScreen> createState() => _SongPlayScreenState();
}

class _SongPlayScreenState extends State<SongPlayScreen> {
  late Map<String, dynamic> currentSong;
  bool isPlayingSong = false;
  late Duration songDuration = Duration.zero;
  late Duration currentPosition = Duration.zero;

  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void dispose() {
    assetsAudioPlayer.pause();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentSong = widget.songsList[widget.currentIndex];
    startAudioPlayer();
    assetsAudioPlayer.currentPosition.listen((event) {
      setState(() {
        currentPosition = event;
      });
    });
    assetsAudioPlayer.current.listen((playingAudio) {
      if (playingAudio != null && playingAudio.audio.duration != null) {
        setState(() {
          songDuration = playingAudio.audio.duration!;
        });
      }
    });
  }

  void startAudioPlayer() {
    List<Audio> audioSongsList = [];
    for (var song in widget.songsList) {
      audioSongsList.add(Audio.network(song['file']));
    }
    assetsAudioPlayer.open(
      Playlist(audios: audioSongsList),
      loopMode: LoopMode.playlist,
      showNotification: true,
      autoStart: false,
      playInBackground: PlayInBackground.disabledPause,
    );
    assetsAudioPlayer.pause();
    assetsAudioPlayer.playlistPlayAtIndex(widget.currentIndex);
    setState(() {
      isPlayingSong = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await assetsAudioPlayer.pause();
        await assetsAudioPlayer.stop();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Musicly Player"),
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
            child: SingleChildScrollView(
              child: buildSongDetails(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSongDetails() {
    if (currentSong.isEmpty) {
      return const Center(
        child: Text("Loading...."),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.white.withOpacity(0.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          buildAvatar(),
          const SizedBox(
            height: 20,
          ),
          buildSongName(),
          const SizedBox(
            height: 20,
          ),
          buildPlayers(),
          const SizedBox(height: 20),
          buildSlider(),
        ],
      ),
    );
  }

  Widget buildAvatar() {
    final double width = MediaQuery.of(context).size.width * 0.6;
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(300.0),
        image: DecorationImage(
          image: NetworkImage(albumImages[currentSong['album']]!),
          fit: BoxFit.cover,
        ),
      ),
      child: const Text(''),
    );
  }

  Widget buildSongName() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Text(
        widget.songsList[widget.currentIndex]['name'],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: lightMode.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget buildPlayers() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              assetsAudioPlayer.pause();
              assetsAudioPlayer.previous();
              if (widget.currentIndex <= 0) {
                setState(() {
                  widget.currentIndex = widget.songsList.length - 1;
                });
              } else {
                setState(() {
                  widget.currentIndex -= 1;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: lightMode.primaryColor),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Icon(
                CupertinoIcons.backward_end_alt,
                color: lightMode.primaryColor,
                size: 40,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (isPlayingSong) {
                assetsAudioPlayer.pause();
                setState(() {
                  isPlayingSong = false;
                });
              } else {
                assetsAudioPlayer.play();
                setState(() {
                  isPlayingSong = true;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: lightMode.primaryColor),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Icon(
                isPlayingSong ? CupertinoIcons.pause : CupertinoIcons.play,
                color: lightMode.primaryColor,
                size: 40,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              assetsAudioPlayer.pause();
              assetsAudioPlayer.next();
              if (widget.currentIndex >= widget.songsList.length - 1) {
                setState(() {
                  widget.currentIndex = 0;
                });
              } else {
                setState(() {
                  widget.currentIndex += 1;
                });
              }
              assetsAudioPlayer.stop(); // Stop the current song
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: lightMode.primaryColor),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Icon(
                CupertinoIcons.forward_end_alt,
                color: lightMode.primaryColor,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider() {
    return Column(
      children: [
        Slider(
          value: currentPosition.inSeconds.toDouble(),
          min: 0.0,
          max: songDuration.inSeconds.toDouble(),
          onChanged: (double value) {
            setState(() {
              assetsAudioPlayer.seek(Duration(seconds: value.toInt()));
            });
          },
          activeColor: lightMode.primaryColor,
          inactiveColor: lightMode.primaryColor.withOpacity(0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(currentPosition),
                style: TextStyle(color: Colors.black),
              ),
              Text(
                formatDuration(songDuration),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? "${twoDigits(duration.inHours)}:" : ""}$twoDigitMinutes:$twoDigitSeconds";
  }
}


//   Widget buildSlider() {
//     return Slider(
//       value: currentPosition.inSeconds.toDouble(),
//       min: 0.0,
//       max: songDuration.inSeconds.toDouble(),
//       onChanged: (double value) {
//         setState(() {
//           assetsAudioPlayer.seek(Duration(seconds: value.toInt()));
//         });
//       },
//       activeColor: lightMode.primaryColor,
//       inactiveColor: lightMode.primaryColor.withOpacity(0.5),
//     );
//   }
// }






























////new code

// import 'package:flutter/material.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:musicly/theme/theme.dart';
// import 'package:musicly/utils/constants.dart';

// class SongPlayScreen extends StatefulWidget {
//   SongPlayScreen(
//       {Key? key, required this.songsList, required this.currentIndex})
//       : super(key: key);

//   final List<Map<String, dynamic>> songsList;
//   int currentIndex;

//   @override
//   State<SongPlayScreen> createState() => _SongPlayScreenState();
// }

// class _SongPlayScreenState extends State<SongPlayScreen> {
//   late Map<String, dynamic> currentSong;
//   bool isPlayingSong = false;
//   late Duration songDuration = Duration.zero;
//   late Duration currentPosition = Duration.zero;

//   final assetsAudioPlayer = AssetsAudioPlayer();

//   @override
//   void dispose() {
//     assetsAudioPlayer.pause();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     currentSong = widget.songsList[widget.currentIndex];
//     startAudioPlayer();
//     assetsAudioPlayer.currentPosition.listen((event) {
//       setState(() {
//         currentPosition = event;
//       });
//     });
//     assetsAudioPlayer.current.listen((playingAudio) {
//       if (playingAudio != null && playingAudio.audio.duration != null) {
//         setState(() {
//           songDuration = playingAudio.audio.duration!;
//         });
//       }
//     });
//   }

//   void startAudioPlayer() {
//     List<Audio> audioSongsList = [];
//     for (var song in widget.songsList) {
//       audioSongsList.add(Audio.network(song['file']));
//     }
//     assetsAudioPlayer.open(
//       Playlist(audios: audioSongsList),
//       loopMode: LoopMode.playlist,
//       showNotification: true,
//       autoStart: false,
//       playInBackground: PlayInBackground.disabledPause,
//     );
//     assetsAudioPlayer.pause();
//     assetsAudioPlayer.playlistPlayAtIndex(widget.currentIndex);
//     setState(() {
//       isPlayingSong = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await assetsAudioPlayer.pause();
//         await assetsAudioPlayer.stop();
//         return true;
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         appBar: AppBar(
//           title: const Text("Musicly Player"),
//         ),
//         body: SafeArea(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bg2.jpeg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: SingleChildScrollView(
//               child: buildSongDetails(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildSongDetails() {
//     if (currentSong.isEmpty) {
//       return const Center(
//         child: Text("Loading...."),
//       );
//     }
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height * 0.85,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6.0),
//         color: Colors.white.withOpacity(0.4),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           buildAvatar(),
//           const SizedBox(
//             height: 20,
//           ),
//           buildSongName(),
//           const SizedBox(
//             height: 20,
//           ),
//           buildPlayers(),
//           const SizedBox(height: 20),
//           buildSlider(),
//         ],
//       ),
//     );
//   }

//   Widget buildAvatar() {
//     final double width = MediaQuery.of(context).size.width * 0.6;
//     return Container(
//       width: width,
//       height: width,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(300.0),
//           image: DecorationImage(
//               image: NetworkImage(albumImages[currentSong['album']]!),
//               fit: BoxFit.cover)),
//       child: const Text(''),
//     );
//   }

//   Widget buildSongName() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white.withOpacity(0.2),
//       ),
//       child: Text(
//         widget.songsList[widget.currentIndex]['name'],
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontSize: 20,
//             color: lightMode.primaryColor,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 4),
//       ),
//     );
//   }

//   Widget buildPlayers() {
//     return Container(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           InkWell(
//             onTap: () {
//               assetsAudioPlayer.pause();
//               assetsAudioPlayer.previous();
//               if (widget.currentIndex <= 0) {
//                 setState(() {
//                   widget.currentIndex = widget.songsList.length - 1;
//                 });
//               } else {
//                 setState(() {
//                   widget.currentIndex -= 1;
//                 });
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 CupertinoIcons.backward_end_alt,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               if (isPlayingSong) {
//                 assetsAudioPlayer.pause();
//                 setState(() {
//                   isPlayingSong = false;
//                 });
//               } else {
//                 assetsAudioPlayer.play();
//                 setState(() {
//                   isPlayingSong = true;
//                 });
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 isPlayingSong ? CupertinoIcons.pause : CupertinoIcons.play,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               assetsAudioPlayer.pause();
//               assetsAudioPlayer.next();
//               if (widget.currentIndex >= widget.songsList.length - 1) {
//                 setState(() {
//                   widget.currentIndex = 0;
//                 });
//               } else {
//                 setState(() {
//                   widget.currentIndex += 1;
//                 });
//               }
//               assetsAudioPlayer.stop(); // Stop the current song
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 CupertinoIcons.forward_end_alt,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSlider() {
//     return Slider(
//       value: currentPosition.inSeconds.toDouble(),
//       min: 0.0,
//       max: songDuration.inSeconds.toDouble(),
//       onChanged: (double value) {
//         setState(() {
//           assetsAudioPlayer.seek(Duration(seconds: value.toInt()));
//         });
//       },
//       activeColor: lightMode.primaryColor,
//       inactiveColor: lightMode.primaryColor.withOpacity(0.5),
//     );
//   }
// }

               




       


///new code







// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:musicly/theme/theme.dart';
// import 'package:musicly/utils/constants.dart';

// class SongPlayScreen extends StatefulWidget {
//   SongPlayScreen(
//       {super.key, required this.songsList, required this.currentIndex});

//   late List<Map<String, dynamic>> songsList;
//   late int currentIndex;
//   @override
//   State<SongPlayScreen> createState() => _SongPlayScreenState();
// }

// class _SongPlayScreenState extends State<SongPlayScreen> {
//   Map<String, dynamic> currentSong = {};
//   bool isPlayingSong = false;

//   final assetsAudioPlayer = AssetsAudioPlayer();

//   @override
//   void dispose() {
//     assetsAudioPlayer.pause();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     currentSong = widget.songsList[widget.currentIndex];
//     setState(() {
//       currentSong;
//     });
//     startAudioPlayer();
//     super.initState();
//   }

//   void startAudioPlayer() {
//     List<Audio> audioSongsList = [];
//     for (var song in widget.songsList) {
//       audioSongsList.add(Audio.network(song['file']));
//     }
//     assetsAudioPlayer.open(
//       Playlist(audios: audioSongsList),
//       loopMode: LoopMode.playlist,
//       showNotification: true,
//       autoStart: false,
//       playInBackground: PlayInBackground.disabledPause,
//     );
//     print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
//     print(audioSongsList);
//     print(audioSongsList[widget.currentIndex]);
//     print(widget.currentIndex);
//     print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

//     assetsAudioPlayer.pause();
//     assetsAudioPlayer.playlistPlayAtIndex(widget.currentIndex);
//     setState(() {
//       isPlayingSong = true;
//     });
//   }

//   @override
  ///commented
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvoked: (didPop) async {
//         await assetsAudioPlayer.pause();
//         await assetsAudioPlayer.stop();
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         appBar: AppBar(
//           title: const Text("Musicly Player"),
//         ),
//         body: SafeArea(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bg2.jpeg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: SingleChildScrollView(
//               child: buildSongDetails(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildSongDetails() {
//     if (currentSong.isEmpty) {
//       return const Center(
//         child: Text("Loading...."),
//       );
//     }
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height * 0.85,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6.0),
//         color: Colors.white.withOpacity(0.4),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           buildAvatar(),
//           const SizedBox(
//             height: 20,
//           ),
//           buildSongName(),
//           const SizedBox(
//             height: 20,
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           buildPlayers(),
//         ],
//       ),
//     );
//   }

//   Widget buildAvatar() {
//     final double width = MediaQuery.of(context).size.width * 0.6;
//     return Container(
//       width: width,
//       height: width,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(300.0),
//           image: DecorationImage(
//               image: NetworkImage(albumImages[currentSong['album']]!),
//               fit: BoxFit.cover)),
//       child: const Text(''),
//     );
//   }

//   Widget buildSongName() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white.withOpacity(0.2),
//       ),
//       child: Text(
//         widget.songsList[widget.currentIndex]['name'],
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontSize: 20,
//             color: lightMode.primaryColor,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 4),
//       ),
//     );
//   }

//   Widget buildPlayers() {
//     return Container(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           InkWell(
//             onTap: () {
//               assetsAudioPlayer.pause();
//               assetsAudioPlayer.previous();
//               if (widget.currentIndex <= 0) {
//                 widget.currentIndex = widget.songsList.length - 1;
//               } else {
//                 widget.currentIndex -= widget.currentIndex - 1;
//               }
//               setState(() {
//                 widget.currentIndex;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 CupertinoIcons.backward_end_alt,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               if (isPlayingSong) {
//                 assetsAudioPlayer.pause();
//                 setState(() {
//                   isPlayingSong = false;
//                 });
//               } else {
//                 assetsAudioPlayer.play();
//                 setState(() {
//                   isPlayingSong = true;
//                 });
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 isPlayingSong ? CupertinoIcons.pause : CupertinoIcons.play,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               assetsAudioPlayer.pause();
//               assetsAudioPlayer.next();
//               if (widget.currentIndex >= widget.songsList.length - 1) {
//                 widget.currentIndex = 0;
//               } else {
//                 widget.currentIndex = widget.currentIndex + 1;
//               }
//               setState(() {
//                 widget.currentIndex;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 CupertinoIcons.forward_end_alt,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
 ///commented
 
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await assetsAudioPlayer.pause();
//         await assetsAudioPlayer.stop();
//         return true;
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         appBar: AppBar(
//           title: const Text("Musicly Player"),
//         ),
//         body: SafeArea(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/bg2.jpeg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: SingleChildScrollView(
//               child: buildSongDetails(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildSongDetails() {
//     if (currentSong.isEmpty) {
//       return const Center(
//         child: Text("Loading...."),
//       );
//     }
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height * 0.85,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6.0),
//         color: Colors.white.withOpacity(0.4),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           buildAvatar(),
//           const SizedBox(
//             height: 20,
//           ),
//           buildSongName(),
//           const SizedBox(
//             height: 20,
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           buildPlayers(),
//         ],
//       ),
//     );
//   }

//   Widget buildAvatar() {
//     final double width = MediaQuery.of(context).size.width * 0.6;
//     return Container(
//       width: width,
//       height: width,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(300.0),
//           image: DecorationImage(
//               image: NetworkImage(albumImages[currentSong['album']]!),
//               fit: BoxFit.cover)),
//       child: const Text(''),
//     );
//   }

//   Widget buildSongName() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white.withOpacity(0.2),
//       ),
//       child: Text(
//         widget.songsList[widget.currentIndex]['name'],
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontSize: 20,
//             color: lightMode.primaryColor,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 4),
//       ),
//     );
//   }

//   Widget buildPlayers() {
//     return Container(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           InkWell(
//             onTap: () {
//               assetsAudioPlayer.pause();
//               assetsAudioPlayer.previous();
//               if (widget.currentIndex <= 0) {
//                 widget.currentIndex = widget.songsList.length - 1;
//               } else {
//                 widget.currentIndex -= 1;
//               }
//               setState(() {
//                 widget.currentIndex;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 CupertinoIcons.backward_end_alt,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               if (isPlayingSong) {
//                 assetsAudioPlayer.pause();
//                 setState(() {
//                   isPlayingSong = false;
//                 });
//               } else {
//                 assetsAudioPlayer.play();
//                 setState(() {
//                   isPlayingSong = true;
//                 });
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 isPlayingSong ? CupertinoIcons.pause : CupertinoIcons.play,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               assetsAudioPlayer.pause();
//               assetsAudioPlayer.next();
//               if (widget.currentIndex >= widget.songsList.length - 1) {
//                 widget.currentIndex = 0;
//               } else {
//                 widget.currentIndex += 1;
//               }
//               assetsAudioPlayer.stop(); // Stop the current song
//               setState(() {
//                 widget.currentIndex;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: lightMode.primaryColor),
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               child: Icon(
//                 CupertinoIcons.forward_end_alt,
//                 color: lightMode.primaryColor,
//                 size: 40,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
