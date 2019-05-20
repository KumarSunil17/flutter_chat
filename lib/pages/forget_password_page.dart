import 'package:flutter/material.dart';
import 'package:flutter_chat/ui_components/Utils.dart';
import 'package:flutter_chat/ui_components/toast.dart';
import 'package:flutter_chat/main.dart';

class ForgetPasswordPage extends StatefulWidget {
  ForgetPasswordPage();

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }
  _handleForgetPassword(){
    auth.sendPasswordResetEmail(email: _emailController.text).then((v){
      Toast.show('Emnail sent', context);
      Navigator.of(context).pop();
    }).catchError((error){
      Toast.show(error.toString(),context);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      insetAnimationCurve: Curves.fastOutSlowIn,
      insetAnimationDuration: Duration(milliseconds: 400),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20.0,top: 20.0, right: 20.0),
            child: inputBox(context, _emailController, TextInputType.emailAddress, "Enter your Registered Email"),
          ),
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 15.0,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.0,),
                width: _width/3,
                child: buttons(context,"Cancel", (){
                  Navigator.of(context).pop();
                }),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.0,),
                width: _width/3,
                child: buttons(context,"Send Email", (){
                  _handleForgetPassword();
                }),
              )
            ],
          ),
        ],
      ),
    );
  }
}
