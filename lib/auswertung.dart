import 'package:tremor_detection/storage.dart';
import 'package:flutter/material.dart';

class Auswertung extends StatelessWidget {
  final StoreObject data;

  const Auswertung({super.key,required this.data});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Auswertung"),
      ),
      body:
        CustomScrollView(
        slivers: <Widget>[
          SliverList.list(
            children: [ LayoutBuilder(builder: (context, constraints){
              return CustomPaint(
                painter: AuswertungsPainter(obj: data),
                size: Size(constraints.maxWidth,data.maxY),
              );
            })
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      const Text("Durchschnittliche Abweichung (Pixel)",textAlign: TextAlign.left),
                      Center(
                        child: Text(data.offsetScore.toStringAsFixed(3),style: const TextStyle(color: Colors.white,fontSize: 50)),
                        )
                    ]
                  )
                ),
                Container(
                  color: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      const Text("Standardabweichung der Zeit zwischen zwei gezeichneten Punkten:",textAlign: TextAlign.left),
                      Center(
                        child: Text(data.timeScore.toStringAsFixed(3),style: const TextStyle(color: Colors.white,fontSize: 50)),
                        )
                    ]
                  )
                ),
                Container(
                  color: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      const Text("Anzahl Bilschirmberührungen:",textAlign: TextAlign.left),
                      Center(
                        child: Text("${data.tabScore}",style: const TextStyle(color: Colors.white,fontSize: 50)),
                        )
                    ]
                  )
                ),
                Container(
                  color: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      const Text("Consistency Score:",textAlign: TextAlign.left),
                      Center(
                        child: Text(data.consistencyScore.toStringAsFixed(3),style: const TextStyle(color: Colors.white,fontSize: 50)),
                        )
                    ]
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuswertungsPainter extends CustomPainter{
  
  
  StoreObject obj;

  AuswertungsPainter({required this.obj});
  
  @override
  void paint(Canvas canvas, Size size) {
      Paint paint = Paint();
      paint.color = Colors.blue;
      paint.strokeWidth = 2.0;
      for (int i = 0; i < obj.vorlagen.length - 1; i++) {
        canvas.drawLine(obj.vorlagen[i], obj.vorlagen[i + 1], paint);
      }

      paint.strokeWidth = 5.0;
      //if()
      for (int i = 0; i < obj.offsets.length - 1; i++) {
        paint.color = Color.fromARGB(255, (obj.abweichungen[i]*8).round(), (255-obj.abweichungen[i]*8).round(), 0);
        canvas.drawLine(obj.offsets[i], obj.offsets[i + 1], paint);
      }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  
}

