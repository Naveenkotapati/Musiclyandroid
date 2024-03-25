import 'package:flutter/material.dart';
import 'package:musicly/screens/album_details.dart';

class LanguageAlbumsScreen extends StatefulWidget {
  const LanguageAlbumsScreen({super.key,  required this.albumsList, required this.lang});

  final List<Map<String, dynamic>> albumsList;
  final String lang;

  @override
  State<LanguageAlbumsScreen> createState() => _LanguageAlbumsScreenState();
}

class _LanguageAlbumsScreenState extends State<LanguageAlbumsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("${widget.lang} Songs"),
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
          child: SingleChildScrollView(child: buildAlbums(),),
        ),
      ),
    );
  }

  Widget buildAlbums(){
    if(widget.albumsList.isEmpty){
      return const Center(child: Text("No Albums Found"),);
    }

    return Container(
      child: Column(
        children: [
          for(var album in widget.albumsList)
            buildAlbumCard(album)
        ],
      ),
    );
  }

  Widget buildAlbumCard(album){
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
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
              height: 200,
              width: MediaQuery.of(context).size.width,
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
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.white.withOpacity(0.5)
              ),
              child: Text(
                album['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 26,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}