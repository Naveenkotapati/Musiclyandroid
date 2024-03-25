import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:musicly/chat/chat.dart';
import 'package:musicly/utils/constants.dart';
import 'package:flutter_chat_types/src/user.dart';

class CommunitChat extends StatefulWidget {
  const CommunitChat({super.key});

  @override
  State<CommunitChat> createState() => _CommunitChatState();
}

class _CommunitChatState extends State<CommunitChat> {

  late types.Room room;
  bool roomExsists=false;
  @override
  void initState() {
    getRoomData();
    super.initState();
  }

  void getRoomData() async{
    final roomResult = await FirebaseFirestore.instance
                .collection('rooms').get();
    if(roomResult.docs.isNotEmpty){
      String roomObjId = roomResult.docs.first.id;
      Map<String, dynamic> roomDetails = roomResult.docs.first.data();
      List<User> users=[];
      for(String userid in roomDetails['userIds']){
        types.User dbUser = types.User(id: userid);
        users.add(dbUser);
      }
      room = types.Room(
          id: roomObjId,
          imageUrl: roomDetails['imageUrl'],
          metadata: const {},
          name: roomDetails['name'],
          type: types.RoomType.group,
          users: users,
        );
      print(room.id);
      roomExsists=true;
      setState(() {
        room;
        roomExsists;
      });
    }else{
      final result = await FirebaseFirestore.instance
                  .collection('users')
                  .where("lastName", isEqualTo: userEmail)
                  .get();
      var userObj = result.docs.first;
      Map<String, dynamic> userJson = userObj.data();
      userJson['id'] = userObj.id;
      types.User user = types.User(id: userObj.id);
      room = await FirebaseChatCore.instance.createGroupRoom(
        imageUrl: 'https://i.pravatar.cc/300',
        users: [user],
        name: "Musicly Community Chat"
      );
      roomExsists=true;
      setState(() {
        room;
        roomExsists;
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    if(roomExsists){
      return ChatPage(
        room: room,
      );
    }
    return const Center(child: Text('Load'),);
  }
}