import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/data_models/Message.dart';
import 'package:flutter_chat/data_models/User.dart';
import 'package:flutter_chat/main.dart';
import 'package:flutter_chat/pages/profile_page.dart';
import 'package:flutter_chat/ui_components/Utils.dart';
import 'package:flutter_chat/ui_components/message_cards.dart';
import 'package:flutter_chat/ui_components/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal/onesignal.dart';

import 'all_users_page.dart';

class PersonalChatPage extends StatefulWidget {
  final User user;

  PersonalChatPage({this.user});

  @override
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  TextEditingController _textEditingController;
  ScrollController listScrollController;
  final FocusNode focusNode = FocusNode();
  bool _isComposingMessage = false;
  DatabaseReference myRef, friendRef, msgRef;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener((onFocusChange));
    listScrollController = ScrollController();
    _textEditingController = TextEditingController();

    setUpReferences();
  }

  setUpReferences() async {
    setState(() {
      _isLoading = true;
    });
    await getCurrentUser().then((curruid) {
      currentUserID = curruid;
      friendRef = FirebaseDatabase.instance
          .reference()
          .child('chat')
          .child(widget.user.uid)
          .child(currentUserID);
      myRef = FirebaseDatabase.instance
          .reference()
          .child('chat')
          .child(currentUserID)
          .child(widget.user.uid);
      msgRef = FirebaseDatabase.instance.reference().child("message");
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      print('error' + error.toString());
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    listScrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        listScrollController.animateTo(
            listScrollController.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: Duration(microseconds: 1));
      });
    }
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });

    listScrollController.jumpTo(listScrollController.position.minScrollExtent);
    if (text.isNotEmpty) {
      _sendMessage(messageText: text, imageUrl: null);
    }
  }

  void _sendMessage({String messageText, String imageUrl}) async {
    String key = msgRef.push().key;
    await msgRef.child(key).update(<String, String>{
      'text': messageText,
      'imageUrl': imageUrl,
      'time': DateTime.now().toLocal().toString().substring(0, 16),
      'sender': currentUserID,
    }).then((v) async {
      String msgKey = myRef.push().key;
      await myRef.child(msgKey).child("id").set(key).then((v) async {
        await friendRef.child(msgKey).child("id").set(key).then((v) async {
          var notification = OSCreateNotification(
            playerIds: [widget.user.playerID],
            content: messageText,
            languageCode: 'ln',
            heading: currentUser.name,
            additionalData: <String, String>{"userid": currentUserID},
            bigPicture: imageUrl,
          );
          await OneSignal.shared
              .postNotification(notification)
              .then((response) {
            setState(() {
              _isComposingMessage = false;
            });
            analytics.logEvent(name: 'send_message');
          });
        });
      });
    });
  }

  void _deleteMessage(Message _msg, DataSnapshot snapshot) async {
    setState(() {
      _isComposingMessage = true;
    });

    if (_msg.imageURL.isNotEmpty) {
      StorageReference storageReference =
          await FirebaseStorage.instance.getReferenceFromUrl(_msg.imageURL);
      await storageReference.delete().then((v) async {
        await msgRef.child(snapshot.value['id']).remove().then((v) async {
          await friendRef.child(snapshot.key).remove().then((v) async {
            await myRef.child(snapshot.key).remove().then((v) {
              setState(() {
                _isComposingMessage = false;
              });
              Toast.show('Message deleted!', context);
            }).catchError((error) {
              Toast.show(error.toString(), context);
            });
          }).catchError((error) {
            Toast.show(error.toString(), context);
          });
        }).catchError((error) {
          Toast.show(error.toString(), context);
        });
      });
    } else {
      await msgRef.child(snapshot.value['id']).remove().then((v) async {
        await friendRef.child(snapshot.key).remove().then((v) async {
          await myRef.child(snapshot.key).remove().then((v) {
            setState(() {
              _isComposingMessage = false;
            });
            Toast.show('Message deleted!', context);
          }).catchError((error) {
            Toast.show(error.toString(), context);
          });
        }).catchError((error) {
          Toast.show(error.toString(), context);
        });
      }).catchError((error) {
        Toast.show(error.toString(), context);
      });
    }
  }

  _sendImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((file) async {
      setState(() {
        _isComposingMessage = true;
      });
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child("chat_images")
          .child("img_" + timestamp.toString() + ".jpg");
      try {
        StorageUploadTask uploadTask = storageReference.putFile(file);
        StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
        String url = await downloadUrl.ref.getDownloadURL();
        _sendMessage(messageText: null, imageUrl: url);
        setState(() {
          _isComposingMessage = false;
        });
      } catch (error) {
        print("upload error" + error.toString());
      }
      setState(() {
        _isComposingMessage = false;
      });
    }).catchError(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    _messageBox() {
      return Container(
        child: _isComposingMessage
            ? Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(child: CircularProgressIndicator()))
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Material(
                    type: MaterialType.circle,
                    color: Colors.transparent,
                    child: IconButton(
                      color: Colors.transparent,
                      icon: Icon(Icons.camera_alt,
                          size: _width / 12, color: Colors.white70),
                      onPressed: () {
                        _sendImage();
                      },
                    ),
                  ),
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: _height / 4,
                        minWidth: _width / 1.6,
                        maxWidth: _width / 1.6,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          focusNode: focusNode,
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                          //controller: textEditingController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button send message
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Material(
                      color: Theme.of(context).primaryColorDark,
                      type: MaterialType.circle,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(70.0)),
                        splashColor: Theme.of(context).accentColor,
                        onTap: () {
                          _textMessageSubmitted(_textEditingController.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.send,
                            size: _width / 15,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        width: double.infinity,
        color: Theme.of(context).primaryColorLight,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          splashColor: Colors.black12.withOpacity(0.1),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ProfilePage(widget.user)));
          },
          child: Container(
            height: _height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Material(
                    type: MaterialType.circle,
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: CachedNetworkImage(
                      errorWidget: (context, error, object) {
                        return Container(
                          child: CircularProgressIndicator(),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        );
                      },
                      imageUrl: widget.user.photoURL,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  widget.user.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        elevation: 3.0,
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            tooltip: 'Coming soon',
            icon: Icon(
              Icons.more_vert,
            ),
            onPressed: () {
              Toast.show('New feature coming soon. Bahut Hard', context);
            },
          ),
        ],
      ),
      body: Material(
        color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: <Widget>[
                  Flexible(
                    child: FirebaseAnimatedList(
                      query: myRef,
                      reverse: true,
                      sort: (a, b) => b.key.compareTo(a.key),
                      controller: listScrollController,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Message _msg = Message(
                            time: "", text: "", sender: "", imageURL: "");
                        return snapshot != null
                            ? StreamBuilder(
                                stream:
                                    msgRef.child(snapshot.value['id']).onValue,
                                builder: (context, snap) {
                                  if (snap.hasData &&
                                      !snap.hasError &&
                                      snap.data.snapshot.value != null) {
                                    _msg.sender = snap
                                        .data.snapshot.value['sender']
                                        .toString();
                                    _msg.text = snap.data.snapshot.value['text']
                                        .toString();
                                    _msg.time = snap.data.snapshot.value['time']
                                        .toString();
                                    snap.data.snapshot.value['imageUrl'] != null
                                        ? _msg.imageURL = snap
                                            .data.snapshot.value['imageUrl']
                                            .toString()
                                        : _msg.imageURL = "";
                                  }
                                  return InkWell(
                                    onLongPress: () {
                                      confirmModalSheet(
                                          context, 'Delete message', () async {
                                        _deleteMessage(_msg, snapshot);
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    // splashColor: Colors.transparent,
                                    highlightColor: Color(0xFF002540),
                                    child: MessageCard(
                                      msg: _msg,
                                      animation: animation,
                                    ),
                                  );
                                },
                              )
                            : Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  _messageBox(),
                ],
              ),
      ),
    );
  }
}
