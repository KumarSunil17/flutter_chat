import 'package:flutter/material.dart';

class InputShape extends CustomPainter {
  Color color;
  bool isBox;

  InputShape({this.color, this.isBox});
  @override
  void paint(Canvas canvas, Size size) {
    Paint stroke = new Paint()
      ..color = this.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint color = new Paint()
    ..color = this.color;

    var path1 = Path();
    path1.addPolygon([
      Offset(size.height/3, 0.0),
      Offset(size.width, 0.0),
      Offset(size.width, (2*size.height)/3),
      Offset(size.width-(size.height/3), size.height),
      Offset(0.0, size.height),
      Offset(0.0, size.height/3),
    ], true);

    canvas.drawPath(path1, isBox ? color : stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}