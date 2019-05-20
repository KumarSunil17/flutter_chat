import 'package:flutter/material.dart';
import 'package:flutter_chat/ui_components/input_card_shape.dart';

Widget inputBox(BuildContext context, TextEditingController controller, TextInputType inputType, String hintText){
  return CustomPaint(
    painter: InputShape(
      color: Color(0xFFF60100),
      isBox: false,
    ),
    child: Container(
      alignment: Alignment.center,
      child: TextField(
        keyboardType: inputType,
        obscureText: hintText == "Password" ? true : false,
        style: TextStyle(
          fontSize: 18.0,
          color: Theme.of(context).textSelectionColor,
        ),
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 18.0,
              color:Theme.of(context).textSelectionColor.withOpacity(0.7),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0)
        ),
      ),
    ),
  );
}
Widget buttons(BuildContext context, String text, Function onPressed){
  return CustomPaint(
      painter: InputShape(
          color: Color(0xFFF60100),
          isBox: true
      ),
      child: FlatButton(
        onPressed: (){
          onPressed();
        },
        child: Container(
          height: 50.0,
          alignment: Alignment.center,
          child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textSelectionColor,
              fontSize: 18.0,
            ),
          ),
        ),
      )
  );
}

confirmModalSheet(BuildContext context, String message, Function onOkPressed){
  showModalBottomSheet(context: context, builder: (context){
    return Container(
      height: 140.0,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: Column(
        children: <Widget>[
          RawMaterialButton(
            onPressed: onOkPressed,
            child: Container(
                height: 80.0,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(message, style: TextStyle(fontSize: 18.0,color: Theme.of(context).accentColor),)
            ),
          ),
          Divider(
            height: 1.0,
            color: Colors.black38,
          ),
          RawMaterialButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Container(
              height: 59.0,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Text('Cancel', style: TextStyle(fontSize: 16.0,color: Colors.black,)
            ),
          ),
          )
        ],
      ),
    );
  });
}