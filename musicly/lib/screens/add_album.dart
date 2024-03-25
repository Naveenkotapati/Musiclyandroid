import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';
import 'package:musicly/utils/loader.dart';
import 'package:intl/intl.dart';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({super.key});

  @override
  State<AddAlbumScreen> createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late File _selectedImage;
  late String _selectedImageName;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    configLoading();
    super.initState();
  }

  void addAlbum(name, language, genre, File file) async {
    EasyLoading.show(status: 'adding...');
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      Reference reference =
          _storage.ref().child("images/$_selectedImageName-$formattedDate");
      TaskSnapshot uploadTask = await reference.putFile(file);
      String location = await reference.getDownloadURL();
      CollectionReference album =
          FirebaseFirestore.instance.collection('albums');
      album.add({
        'name': name,
        'language': language,
        'genre': genre,
        'file': location
      }).then((value) {
        print("Album added");
      }).catchError((error) {
        print("Failed to add album: $error");
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
        title: const Text("Add Album"),
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
            child: buildAddAlbumForm(),
          ),
        ),
      ),
    );
  }

  Widget buildAddAlbumForm() {
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
                  hintText: 'Enter Album Name',
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
                      borderSide: BorderSide(
                    color: lightColorScheme.primary,
                  ))),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderDropdown(
              name: "Language",
              decoration: InputDecoration(
                  label: const Text('Language'),
                  hintText: 'Select Language Name',
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
                      borderSide: BorderSide(
                    color: lightColorScheme.primary,
                  ))),
              items: languages
                  .map((serviceGroupName) => DropdownMenuItem(
                        alignment: AlignmentDirectional.center,
                        value: serviceGroupName,
                        child: Text(serviceGroupName),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: 'Genre',
              decoration: InputDecoration(
                  label: const Text('Genre'),
                  hintText: 'Enter Genre Name',
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
                      borderSide: BorderSide(
                    color: lightColorScheme.primary,
                  ))),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(
              height: 10,
            ),
            FormBuilderFilePicker(
              allowMultiple: false,
              maxFiles: 1,
              name: "AlbumImage",
              decoration: InputDecoration(
                  label: const Text('Add Album Image'),
                  hintText: 'Upload Album Image',
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
                      borderSide: BorderSide(
                    color: lightColorScheme.primary,
                  ))),
              previewImages: true,
              onChanged: (val) {
                if (val!.isNotEmpty) {
                  final List<PlatformFile> selectedImages = val;
                  print("################");
                  print(selectedImages.first.path);
                  print(File(selectedImages.first.path.toString()));
                  _selectedImage = File(selectedImages.first.path.toString());
                  _selectedImageName = selectedImages.first.name;
                  print("################");
                }
              },
              typeSelectors: const [
                TypeSelector(
                  type: FileType.image,
                  selector: Row(
                    children: <Widget>[
                      Icon(Icons.upload_file),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text("Add Album Image"),
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
                if (_formKey.currentState!.validate() &&
                    _selectedImage.path.isNotEmpty) {
                  debugPrint(_formKey.currentState?.instantValue.toString());
                  Map<String, dynamic> formData =
                      _formKey.currentState!.instantValue;
                  addAlbum(formData['Name'], formData['Language'],
                      formData['Genre'], _selectedImage);
                  _formKey.currentState!.reset();
                } else {
                  EasyLoading.showError("Please fill all details");
                }
              },
              child: const Text(
                'Add Album',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
