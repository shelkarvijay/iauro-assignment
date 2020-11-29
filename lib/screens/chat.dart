import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iauro_assignment/helper/constants.dart';
import 'package:iauro_assignment/helper/theme.dart';
import 'package:iauro_assignment/services/database.dart';
import 'package:iauro_assignment/widget/widget.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String userName;

  Chat({this.chatRoomId, this.userName});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].get("message"),
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].get("sendBy"),
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.userName[0].toUpperCase()}${widget.userName.substring(1)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: CustomTheme.appThemeColor,
      ),
      body: Container(
        color: Colors.grey[300],
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                padding: EdgeInsets.all(10),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: messageEditingController,
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                              hintText: "Type a message",
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 17,
                              ),
                              border: InputBorder.none),
                        )),
                        SizedBox(
                          width: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            addMessage();
                          },
                          child: Container(
                              padding: EdgeInsets.only(right: 6),
                              child: CircleAvatar(
                                radius: 20.0,
                                child: Icon(Icons.send),
                                backgroundColor: CustomTheme.appThemeColor,
                              )),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Color(0xFFDCF8C6),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Color(0x22000000),
              offset: Offset(1, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
