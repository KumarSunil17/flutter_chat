import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/data_models/User.dart';
import 'package:flutter_chat/ui_components/input_card_shape.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage(this.user);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;

    _scrollController = ScrollController(initialScrollOffset: _height/3);

    return  widget.user != null ? Scaffold(
      body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
            return <Widget>[
              SliverAppBar(
                expandedHeight: _height/1.5,
                floating: false,
                pinned: true,
                iconTheme: IconThemeData(color: Colors.blue),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.user.name, style: TextStyle(color: Colors.white, fontSize: 18.0),),
                  background:  CachedNetworkImage(
                    errorWidget: (context, error, object){
                      return Container(
                        child: Center(child: CircularProgressIndicator()),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      );
                    },
                    imageUrl: widget.user.photoURL,
                    fit: BoxFit.cover,
                  ),
//                Image.asset(
//                  'dashboard_background.png',
//                  fit: BoxFit.cover,
//                ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child:Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomPaint(
                painter: InputShape(
                color: Color(0xFFF60100),
                isBox: false
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  child: Text(widget.user.email),
                ),
              ),
            ) ,
          ),
      ),
    ): Center(child: CircularProgressIndicator(),);
  }
}
