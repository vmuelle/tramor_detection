import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:tremor_detection/drawing.dart';


class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Tremor detection App"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DrawingCanvas(toPaint: SpiralPainter())),
                );
              },
              child: const Text("Draw Spiral")
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DrawingCanvas(toPaint: LinePainter())),
                );
              },
              child: const Text("Draw Line")
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DrawingCanvas(toPaint: SinPainter())),
                );
              },
              child: const Text("Draw Sinus")
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DrawingCanvas(toPaint: PulsePainter())),
                );
              },
              child: const Text("Draw Pulse")
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DrawingCanvas(toPaint: RampPainter())),
                );
              },
              child: const Text("Draw Ramp")
            ),
          ],
        ),
      ),
    );
  }
}


class SpiralPainter extends PatternPainter {

  @override
  final String name = "spirale";

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 2.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.sqrt(centerX * centerX + centerY * centerY);

    var lastX = centerX;
    var lastY = centerY;
    for (var i = 0; i < 360 * 6; i += 6) {
      final angle = i * math.pi / 180;
      final radius = maxRadius * i / (360 * 6);

      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if(x > size.width-20 || x < 20 || y > size.height-20 || y < 20){
        break;
      }
      canvas.drawLine(Offset(x, y), Offset(lastX,lastY), paint);
      lastX = x;
      lastY = y;
    }

    if(offsets.isEmpty){
    var lastX = centerX;
    var lastY = centerY;
    offsets.add(Offset(lastX,lastY));
    for (var i = 0; i < 360 * 6; i += 6) {
      final angle = i * math.pi / 180;
      final radius = maxRadius * i / (360 * 6);

      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if(x > size.width-20 || x < 20 || y > size.height-20 || y < 20){
        break;
      }
      offsets.add(Offset(x,y));
      lastX = x;
      lastY = y;
    }
    }


    start = Offset(centerX,centerY);
    stop = Offset(lastX,lastY);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LinePainter extends PatternPainter {

  @override
  final String name = "line";

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 2.0;

    final centerY = size.height / 2;
   
    canvas.drawLine(Offset(0, centerY), Offset(size.width,centerY), paint);
    start = Offset(0,centerY);
    stop = Offset(size.width,centerY);
    if(offsets.isEmpty){
      for (double i = 0; i<= size.width; i++ ){
        offsets.add(Offset(i,centerY));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SinPainter extends PatternPainter {

  @override
  final String name = "sinus";

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 2.0;

    final centerY = size.height / 2;
    final amplitude = size.height/10;
    double lastY = centerY;
    
    for (double x = 5; x <= size.width-5; x++) {
      final stepSize = 4*math.pi/size.width;
      final y = (amplitude*math.sin((x*stepSize)))+centerY;
      canvas.drawLine(Offset(x-1, lastY), Offset(x,y), paint);
      lastY = y;
    }
    if (offsets.isEmpty){
    offsets.add(Offset(4,centerY));
    for (double x = 5; x <= size.width-5; x++) {
      final stepSize = 4*math.pi/size.width;
      final y = (amplitude*math.sin((x*stepSize)))+centerY;
      offsets.add(Offset(x,y));
      lastY = y;
    }
    }
    start = Offset(4,centerY);
    stop = Offset(size.width-5,lastY);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PulsePainter extends PatternPainter {

  @override
  final String name = "pulse";

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 2.0;

    start = Offset(5,2*size.height/3);
    stop = Offset(size.width-5,2*size.height/3);

    canvas.drawLine(start, Offset(size.width/6,2*size.height/3), paint);
    canvas.drawLine(Offset(size.width/6,2*size.height/3), Offset(size.width/6,size.height/3), paint);
    canvas.drawLine(Offset(size.width/6,size.height/3), Offset(5*size.width/6,size.height/3), paint);
    canvas.drawLine(Offset(5*size.width/6,size.height/3), Offset(5*size.width/6,2*size.height/3), paint);
    canvas.drawLine(Offset(5*size.width/6,2*size.height/3), stop, paint);
    if(offsets.isEmpty){
    for (double i = 0; i< size.width; i++ ){
      if (i < size.width/6 || i > 5*size.width/6){
        offsets.add(Offset(i,2*size.height/3));
      }else if(i == size.width/6){
        for (double j = 2*size.height/3; j >= size.height/3; j--){
          offsets.add(Offset(i,j));
        }
      }else if(i == 5*size.width/6){
        for (double j = size.height/3; j <= 2*size.height/3; j++){
          offsets.add(Offset(i,j));
        }
      }else if(i > size.width/6 && i < 5*size.width/6){
        offsets.add(Offset(i,size.height/3));
      }
    }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RampPainter extends PatternPainter {

  @override
  final String name = "ramp";

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 2.0;
    
    start = Offset(5,2*size.height/3);
    stop = Offset(size.width-5,size.height/3);

    canvas.drawLine(start, Offset(size.width/6,2*size.height/3), paint);
    canvas.drawLine(Offset(size.width/6,2*size.height/3), Offset(5*size.width/6,size.height/3), paint);
    canvas.drawLine(Offset(5*size.width/6,size.height/3), stop, paint);

    if(offsets.isEmpty){
      double incline = (size.height/3)/(4*size.width/6);
      for (double i = 0; i< size.width; i++ ){
        if (i <= size.width/6){
          offsets.add(Offset(i,2*size.height/3));
        }else if(i > size.width/6 && i <= 5*size.width/6){
          offsets.add(Offset(i,(2*size.height/3)-((i-size.width/6)*incline)));
        }else if(i > 5*size.width/6 ){
          offsets.add(Offset(i,size.height/3));
        }
        
      }
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  
}


class PatternPainter extends CustomPainter{
  
  final String name = "";
  Offset start = Offset(0,0);
  Offset stop = Offset(0,0);
  List<Offset> offsets = <Offset>[];

  
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  List<double> abweichungen(List<Offset> painted){
    List<double> abweichungen = <double>[];
    int index = 0;
    for (int i = 0; i < painted.length; i++){
      final (abweichung, idx) =  getMinAbweichung(painted[i],index);
      abweichungen.add(abweichung);
      index = idx;
    }
    return abweichungen;
  }

  (double,int) getMinAbweichung(Offset painted,int i){
    double minDistance = (offsets[0] - painted).distance;
    int index = 0;
    for (i; i < offsets.length; i++){
      final double dis = (offsets[i]-painted).distance;
      if(dis< minDistance) {
        minDistance = dis;
        index = i;
      }
    }
    return (minDistance,index);
  }
  
}
