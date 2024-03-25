import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:musicly/screens/add_album.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';
import 'package:musicly/utils/loader.dart';
import 'package:intl/intl.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late File _selectedSong;
  late String _selectedSongName;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    configLoading();
    super.initState();
  }


  void addAlbumSong(name, album, File file) async{
    EasyLoading.show(status: 'adding...');
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      Reference reference = _storage.ref().child("songs/$formattedDate-$_selectedSongName");
      TaskSnapshot uploadTask = await reference.putFile(file);
      String location = await reference.getDownloadURL();
      CollectionReference albumSong = FirebaseFirestore.instance.collection('songs');
      albumSong.add({
        'name': name,
        'album': album,
        'file': location
      }).then((value) {
        print("Album Song added");
      }).catchError((error) {
        print("Failed to add album Song : $error");
      });
      Navigator.pop(context);
    } catch (e) {
      EasyLoading.showError("Unable to add Album. Error: $e");
      
    }
    EasyLoading.dismiss();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Add Song"),
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
          child: SingleChildScrollView(child: buildAddAlbumForm(),),
        ),
      ),
      floatingActionButton: InkWell(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddAlbumScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            width: 160,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: lightColorScheme.primary.withOpacity(0.8)
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add Album",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
                Icon(
                  CupertinoIcons.music_albums_fill,
                  color: Colors.white,
                  size: 30,
                )
              ],
            ),
          ),
        ),
    );
  }

  Widget buildAddAlbumForm(){
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'Name',
                decoration: InputDecoration(
                  label: const Text('Name'),
                  hintText: 'Enter Song Name',
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
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 10),
              FormBuilderDropdown(
                name: "Album", 
                decoration: InputDecoration(
                  label: const Text('Album'),
                  hintText: 'Select Album Name',
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
                items: albumsNames.map((serviceGroupName) => DropdownMenuItem(
                    alignment: AlignmentDirectional.center,
                    value: serviceGroupName,
                    child: Text(serviceGroupName),
                  )).toList(),
              ),
             const SizedBox(height: 10,),
              FormBuilderFilePicker(
                allowMultiple: false,
                maxFiles: 1,
                name: "Song",
                decoration: InputDecoration(
                  label: const Text('Add Song'),
                  hintText: 'Upload Song',
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
                previewImages: true,
                onChanged: (val){
                  if(val!.isNotEmpty){
                    final List<PlatformFile> selectedFiles = val;
                    print("################");
                    print(selectedFiles.first.path);
                    print(File(selectedFiles.first.path.toString()));
                    _selectedSong = File(selectedFiles.first.path.toString());
                    _selectedSongName = selectedFiles.first.name;
                    print("################");
                  }
                },
                typeSelectors: const [
                  TypeSelector(
                    type: FileType.audio,
                    selector: Row(
                      children: <Widget>[
                        Icon(Icons.upload_file),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Add Album Song"),
                        ),
                      ],
                    ),
                  ),
                ],
                onFileLoading: (val) {
                  print(val);
                },
              ),
              MaterialButton(
                color: lightColorScheme.primary,
                onPressed: () {
                  if(_formKey.currentState!.validate() && _selectedSong.path.isNotEmpty){
                    debugPrint(_formKey.currentState?.instantValue.toString());
                    Map<String, dynamic> formData = _formKey.currentState!.instantValue;
                    addAlbumSong(
                      formData['Name'], 
                      formData['Album'],
                      _selectedSong
                    );
                    _formKey.currentState!.reset();
                  }else{
                    EasyLoading.showError("Please fill all details");
                  }
                },
                child: const Text('Add Album Song', style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
    );
  }

}