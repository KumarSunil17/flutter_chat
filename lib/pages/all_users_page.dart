import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/data_models/User.dart';
import 'package:flutter_chat/main.dart';
import 'package:flutter_chat/pages/login_page.dart';
import 'package:flutter_chat/pages/personal_chat_page.dart';
import 'package:flutter_chat/pages/profile_page.dart';
import 'package:flutter_chat/ui_components/Utils.dart';
import 'package:flutter_chat/ui_components/toast.dart';
import 'package:onesignal/onesignal.dart';

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

User currentUser;

class AllUsersPage extends StatefulWidget {
  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  DatabaseReference _userRef;
  String _currUid;

  List<Choice> choices = const <Choice>[
    const Choice(title: 'Profile', icon: Icons.person),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  bool _isLoading = false;

  Future<Null> _handleSignOut() async {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          var _width = MediaQuery.of(context).size.width;
          return Dialog(
            backgroundColor: Theme.of(context).primaryColor,
            insetAnimationCurve: Curves.fastOutSlowIn,
            insetAnimationDuration: Duration(milliseconds: 400),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
                  child: Text(
                    'Are you sure to signout?',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).textSelectionColor,
                    ),
                  ),
                ),
                Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 15.0,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.0,
                      ),
                      width: _width / 4,
                      child: buttons(context, "Cancel", () {
                        Navigator.of(context).pop();
                      }),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.0,
                      ),
                      width: _width / 4,
                      child: buttons(context, "Yes", () async {
                        this.setState(() {
                          _isLoading = true;
                        });
                        await auth.signOut().then((a) async {
                          await googleSignIn.signOut().then((account) {
                            this.setState(() {
                              _isLoading = false;
                            });

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                (Route<dynamic> route) => false);
                          });
                        });
                      }),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      _handleSignOut();
    } else {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (BuildContext context) => ProfilePage(currentUser)));
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((uid) {
      _currUid = uid;
    });
    _userRef = FirebaseDatabase.instance.reference().child('users');

    OneSignal.shared.setNotificationReceivedHandler((notification) {
      String uid = notification.payload.additionalData["userid"];
      _userRef.child(uid).onValue.listen((e) {
        Toast.show("New Message from " + e.snapshot.value["name"], context);
      });
    });
    OneSignal.shared.setNotificationOpenedHandler((result) async {
      String uid = result.notification.payload.additionalData["userid"];
      _userRef.child(uid).onValue.listen((event) {
        User _user = User(
            name: event.snapshot.value["name"],
            email: event.snapshot.value['email'],
            photoURL: event.snapshot.value['photoUrl'],
            uid: event.snapshot.key,
            playerID: event.snapshot.value['playerid']);
        print('notification_name${_user.name}');
        if (_user != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => PersonalChatPage(
                    user: _user,
                  )));
        }
      });
    });
  }

  Widget buildItem(BuildContext context, DataSnapshot snapshot) {
    User _user = User(
        name: snapshot.value["name"],
        email: snapshot.value['email'],
        photoURL: snapshot.value['photoUrl'],
        uid: snapshot.key,
        playerID: snapshot.value['playerid']);

    if (_currUid == snapshot.key) {
      currentUser = _user;
      return Container();
    } else {
      return ListTile(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => PersonalChatPage(
                        user: _user,
                      )));
        },
        title: Text(
          _user.name,
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        subtitle: Text(
          _user.email,
          style: TextStyle(color: Colors.white70),
        ),
        leading: Material(
          child: CachedNetworkImage(
            errorWidget: (context, error, object) {
              return Container(
                child: CircularProgressIndicator(),
                width: 50.0,
                height: 50.0,
                padding: EdgeInsets.all(15.0),
              );
            },
            imageUrl: _user.photoURL,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover,
          ),
          type: MaterialType.circle,
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Users"),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            tooltip: 'Menu',
            onSelected: _onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Theme.of(context).primaryColorLight,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Material(
          color: Theme.of(context).backgroundColor,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : FirebaseAnimatedList(
                  query: _userRef,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return snapshot != null
                        ? buildItem(context, snapshot)
                        : Center(child: CircularProgressIndicator());
                  },
                ),
        ),
      ),
    );
  }
}
