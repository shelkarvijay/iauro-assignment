import 'package:flutter/material.dart';
import 'package:iauro_assignment/helper/authenticate.dart';
import 'package:iauro_assignment/helper/constants.dart';
import 'package:iauro_assignment/helper/helperfunctions.dart';
import 'package:iauro_assignment/helper/theme.dart';
import 'package:iauro_assignment/screens/chat.dart';
import 'package:iauro_assignment/screens/search.dart';
import 'package:iauro_assignment/services/auth.dart';
import 'package:iauro_assignment/services/database.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  print(
                      '\n\n ***snapshot.data.documents*** ${snapshot.data.documents}');
                  return ChatRoomsTile(
                    userName: snapshot.data.documents[index]
                        .get('chatRoomId')
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId:
                        snapshot.data.documents[index].get("chatRoomId"),
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        // snapshots.collection('chats').orderByChild('time').limitToLast(1).snapshots();
        // print('object---***\n\n ${snapshots.documents}');
        chatRooms = snapshots;
        chatRooms.map((event) {
          print('event****$event');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "WhatsApp",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0.0,
            centerTitle: false,
            backgroundColor: CustomTheme.appThemeColor,
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.camera_alt),
                ),
                Tab(
                  text: "CHATS",
                ),
                Tab(
                  text: "STATUS",
                ),
                Tab(
                  text: "CALLS",
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Search()));
                },
                icon: Icon(Icons.search),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: GestureDetector(
                        onTap: () {
                          AuthService().signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Authenticate()));
                        },
                        child: Container(
                          child: Text("Logout"),
                        )),
                  ),
                ],
              ),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              _getUpcomingContainer('Camera'),
              chatRoomsList(),
              _getUpcomingContainer('Status'),
              _getUpcomingContainer('Calls'),
            ],
          ),
        ));
  }

  _getUpcomingContainer(screenName) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Upcoming feactures',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              screenName,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ));
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({this.userName, @required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.grey[200], width: 1.0))),
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        child: ListTile(
          title: Text(
            userName != ''
                ? '${userName[0].toUpperCase()}${userName.substring(1)}'
                : '',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          dense: true,
          subtitle: Text(''),
          leading: Container(
              width: 50,
              height: 50,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
              )),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          chatRoomId: chatRoomId,
                          userName: userName,
                        )));
          },
        ));
  }
}
