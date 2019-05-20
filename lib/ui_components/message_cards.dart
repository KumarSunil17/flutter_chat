import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/data_models/Message.dart';
import 'package:flutter_chat/ui_components/message_card_shape.dart';

var currentUserID;

class MessageCard extends StatelessWidget {
  final Message msg;
  final Animation animation;
  MessageCard({this.msg, this.animation});

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;

    Widget personalSenderCard(){
      return Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(left: 15.0, right:15.0 ,bottom: 3.0,top: 3.0),
          child: Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              CustomPaint(
                painter: MessageShape(
                  color: Theme.of(context).accentColor,
                  isSender: true,
                ),
                child: msg.imageURL.isEmpty ?
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 10.0, maxWidth: _width/2),
                    child: Text(msg.text,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ) :
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child : CachedNetworkImage(
                    height: 250.0,
                    width: 250.0,
                    errorWidget: (context, error, object){
                      return CircularProgressIndicator();
                    },
                    imageUrl: msg.imageURL,
                    fit: BoxFit.cover,
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 3.0),
                child: Text(msg.time,
                  style: TextStyle(
                    fontSize: 8.0,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        );
    }
    Widget personalReceiverCard() {
      return
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 15.0, right:15.0 ,bottom: 3.0,top: 3.0),
          child: Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              CustomPaint(
                painter: MessageShape(
                  color: Colors.white,
                  isSender: false,
                ),
                child:  msg.imageURL.isEmpty ?
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 5.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 10.0, maxWidth: _width / 2),
                    child: Text(msg.text,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white
                      ),
                    ),
                  ),
                ) :
                Padding(
                    padding: EdgeInsets.all(2.0),
                    child : CachedNetworkImage(
                      height: 250.0,
                      width: 250.0,
                      errorWidget: (context, error, object){
                        return CircularProgressIndicator();
                      },
                      imageUrl: msg.imageURL,
                      fit: BoxFit.cover,
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 3.0),
                child: Text(msg.time,
                  style: TextStyle(
                    fontSize: 8.0,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        );
    }
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.decelerate),
      child: currentUserID == msg.sender
          ? personalSenderCard()
          : personalReceiverCard(),
    );
  }
}