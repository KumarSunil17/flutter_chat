import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/all_users_page.dart';
import 'package:flutter_chat/main.dart';
import 'package:flutter_chat/ui_components/Utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat/ui_components/toast.dart';
import 'package:onesignal/onesignal.dart';

class SignUpPage extends StatefulWidget {
  final DatabaseReference _userRef;

  SignUpPage(this._userRef);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _emailController, _passwordController, _nameController;
  File _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  _handleSignUp() async{
    if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _nameController.text.isNotEmpty && _image != null){
      String _email = _emailController.text.trim();
      String _password = _passwordController.text.trim();
      String _name = _nameController.text.trim();

      setState(() {
        _isLoading = true;
      });
      await OneSignal.shared.getPermissionSubscriptionState().then((status) async {
        String playerId = status.subscriptionStatus.userId;
        await auth.createUserWithEmailAndPassword(email: _email, password: _password).then((user) async{
          if(user != null){
            StorageReference storageReference = FirebaseStorage
                .instance
                .ref()
                .child("user_dps")
                .child(user.uid+".jpg");
            try{
              StorageUploadTask uploadTask = storageReference.putFile(_image);
              StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
              String url = await downloadUrl.ref.getDownloadURL();

              print('URL : $url');
              widget._userRef.child(user.uid).update(<String, String>{
                'email': _email,
                'name': _name,
                'photoUrl': url,
                'playerid':playerId,
              }).then((v){
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (BuildContext context) => AllUsersPage())
                ).then((v){
                  Toast.show("Signup Successfully!", context);
                  Navigator.of(context).pop();
                });
              }).catchError((error){
                Toast.show(error.toString(), context);
                Navigator.of(context).pop();
              });
            }catch(error){
              Toast.show("Upload error"+error.toString(), context);
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pop();
            }
          }else{
            Toast.show('Sign in failed!', context);
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
          }
        }).catchError((error){
          Toast.show(error.toString(), context);
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        });
      });

    }else{
      Toast.show('Field empty', context);
    }
  }

  Future<void> _getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.height/3);
    setState(() {
      _image = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    _inputPicture(){
      return Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: _width,
              height: _width/2.5,
              child: _image != null ?
              Image.file(_image,fit: BoxFit.cover )
                  :
                Center(
                  child:  Text('Please choose your photo',
                    style: TextStyle(color: Colors.white, fontSize: 18.0,),),
                ),
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: RaisedButton(
                  onPressed: (){
                    _getImage();
              },
                color: Theme.of(context).primaryColorLight.withOpacity(0.7),
                child: Icon(Icons.edit, size: 40.0,color: Colors.white,),
              ),
              ),
          ]
        ),
      );
    }

    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      insetAnimationCurve: Curves.fastOutSlowIn,
      insetAnimationDuration: Duration(milliseconds: 400),
      child: _isLoading ?
      Center(child:CircularProgressIndicator())
          :
      SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            _inputPicture(),
            Padding(
              padding: EdgeInsets.only(left: 20.0,top: 20.0, right: 20.0),
              child: inputBox(context, _nameController, TextInputType.text, "Name"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0,top: 20.0, right: 20.0),
              child: inputBox(context, _emailController, TextInputType.emailAddress, "Email"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0,top: 20.0, right: 20.0),
              child: inputBox(context, _passwordController, TextInputType.text, "Password"),
            ),
            Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20.0,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0,),
                  width: _width/3.5,
                  child: buttons(context,"Cancel", (){
                    Navigator.of(context).pop();
                  }),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  width: _width/3.5,
                  child: buttons(context,"Sign Up", (){
                    _handleSignUp();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
