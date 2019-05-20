import 'package:flutter/material.dart';

class MessageShape extends CustomPainter {
  Color color;
  bool isSender;

  MessageShape({this.color, this.isSender});
  @override
  void paint(Canvas canvas, Size size) {
    Paint color = new Paint()
      ..color = this.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

    var path1 = Path();
    path1.addPolygon([
      Offset(0.0, 0.0),
      Offset(size.width, 0.0),
      Offset(size.width, size.height/3.5),
      Offset(size.width+7, (size.height/3.5)+5),
      Offset(size.width, (size.height/3.5)+10),
      Offset(size.width, size.height),
      Offset(0.0, size.height),
    ], true);

    var path2 = Path();
    path2.addPolygon([
      Offset(0, (size.height/3.5)+5),
      Offset(7, size.height/3.5),
      Offset(7, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(7, size.height),
      Offset(7, (size.height/3.5)+10),
    ], true);

    canvas.drawPath(isSender ? path1 : path2, color);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}