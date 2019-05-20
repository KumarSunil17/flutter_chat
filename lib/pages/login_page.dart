import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/all_users_page.dart';
import 'package:flutter_chat/pages/forget_password_page.dart';
import 'package:flutter_chat/pages/signup_page.dart';
import 'package:flutter_chat/ui_components/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat/ui_components/Utils.dart';
import 'package:flutter_chat/main.dart';
import 'package:onesignal/onesignal.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController, _passwordController;
  bool _isLoading = false;
  DatabaseReference _userRef;

  _checkLogin() async{
//    GoogleSignInAccount signedInUser = googleSignIn.currentUser;
//    if (signedInUser != null){
//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (BuildContext context) => AllUsersPage())
//      );
//    }
//    signedInUser = await googleSignIn.signInSilently().catchError((error){
//    showSnackBar(scaffoldKey: _scaffoldKey, text: error.toString());
//    });
//    if (signedInUser != null) {
//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (BuildContext context) => AllUsersPage())
//      );
//    }
    if(await getCurrentUser() != null){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => AllUsersPage())
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _setupController();
    _checkLogin();
    _userRef = FirebaseDatabase.instance.reference().child("users");
  }

  @override
  void dispose() {
    super.dispose();
    _disposeControllers();
  }

  _setupController(){
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  _disposeControllers(){
    _emailController.dispose();
    _passwordController.dispose();
  }

//Sign In methods
  _handleSignInEmailPassword() async{
    setState(() {
      _isLoading = true;
    });
    if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty){
      await OneSignal.shared.getPermissionSubscriptionState().then((status) async{
        String playerId = status.subscriptionStatus.userId;
        await auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text).then((user)async{
          if(user!=null){
            await _userRef.child(user.uid).update({'playerid' : playerId});
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) => AllUsersPage())
            );
            setState(() {
              _isLoading = false;
            });
          }else{
            Toast.show('Login Failed', context);
            setState(() {
              _isLoading = false;
            });
          }
        }).catchError((error){
          Toast.show(error.toString(),context);
          setState(() {
            _isLoading = false;
          });
        });
      });
    }else{
      Toast.show('Field empty', context);
    }
    setState(() {
      _isLoading = false;
    });
  }
  _handleSignInGoogle() async {
    setState(() {
      _isLoading = true;
    });
    GoogleSignInAccount signedInUser = await googleSignIn.signIn();
      analytics.logLogin();

    GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: credentials.accessToken,
      idToken: credentials.idToken,
    );

    await OneSignal.shared.getPermissionSubscriptionState().then((status) async {
      String playerId = status.subscriptionStatus.userId;
      await auth.signInWithCredential(credential).then((user){
        if(user != null){
          _userRef.child(user.uid).update(<String, String>{
            'email': signedInUser.email,
            'name': signedInUser.displayName,
            'photoUrl': signedInUser.photoUrl,
            'playerid' : playerId
          }).then((v){
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) => AllUsersPage())
            );
            setState(() {
              _isLoading = false;
            });
          }).catchError((error){
            Toast.show(error.toString(),context);
            setState(() {
              _isLoading = false;
            });
          });
        }else{
          Toast.show('Unknown error occured',context);
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;

    _signInWithGoogleWidget(){
      return Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text("Continue with Google",
            style: TextStyle(color: Colors.blue, fontSize: 18.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(70.0)),
            onTap: (){
              _handleSignInGoogle();
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Platform.isIOS ?
              Image.asset('ios_google_logo.png',
                fit: BoxFit.cover,
                height: 70.0,
                width: 70.0,
              ) :
              Image.asset("google_logo.png",
                fit: BoxFit.cover,
                height: 70.0,
                width: 70.0,
              ),
            ),
          ),
        ],
      );
    }
    _signUpWidget(){
      return InkWell(
        onTap: (){
          showDialog(
              context: context,
              builder: (context){
                return SignUpPage(_userRef);
              },
              barrierDismissible: false,
          );
        },
        child: Text("Sign Up Here",
          style: TextStyle(color: Colors.blue, fontSize: 18.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      );
    }
    _forgetPasswordWidget(){
      return InkWell(
        onTap: (){
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context){
              return ForgetPasswordPage();
            },
          );
        },
        child: Text("Forgot Password?",
          style: TextStyle(color: Colors.blue, fontSize: 18.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      );
    }

    _buildBody(){
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: _width/8,top: 10.0, right: _width/8),
              child: inputBox(context, _emailController, TextInputType.emailAddress, "Email"),
            ),
            Padding(
              padding: EdgeInsets.only(left: _width/8,top: 10.0, right: _width/8),
              child: inputBox(context, _passwordController, TextInputType.text, "Password"),
            ),

            Padding(
              padding: EdgeInsets.only(left: _width/5,top: 10.0, right: _width/5),
              child: buttons(context,"Login", (){
                _handleSignInEmailPassword();
              }),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _signUpWidget(),
                _forgetPasswordWidget(),
              ],
            ),
            SizedBox(height: 50.0),

            _signInWithGoogleWidget(),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child:  _isLoading ?
        Container(
          child: CircularProgressIndicator(),
        )
            :
        _buildBody(),
      ),
    );
  }
}
