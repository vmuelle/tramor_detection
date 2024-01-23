//überlegung: popup menu bar mit einstellung von parametern
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremor_detection/menu.dart';
import 'package:tremor_detection/storage.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key, required this.toPaint});

  final PatternPainter toPaint;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset> offsets = <Offset>[];
  List<int> noLine = <int>[];
  bool startFlag = false;
  List<DateTime> time = <DateTime>[];
  final filenameController = TextEditingController();
  final Storage storage = Storage();

  bool isinregion(StartStop painter, Offset offset,bool start){
    if(start){
      if (offset.dx < painter.start.dx - painter.width/2 || 
          offset.dx > painter.start.dx + painter.width/2 ||
          offset.dy < painter.start.dy - painter.height/2 ||
          offset.dy > painter.start.dy + painter.height/2){
            return false;  
      }
      else {
        return true;
      }
    }else{
      if (offset.dx < painter.stop.dx - painter.width/2 || 
          offset.dx > painter.stop.dx + painter.width/2 ||
          offset.dy < painter.stop.dy - painter.height/2 ||
          offset.dy > painter.stop.dy + painter.height/2){
            return false;  
      }
      else {
        return true;
      }
    }
  }
  void portraitModeOnly(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    portraitModeOnly();
    PatternPainter basePainter = widget.toPaint;
    StartStop startStopPainter  = StartStop(basePainter: basePainter);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Tremor detection App"),
      ),
      body: Stack(
        children: <Widget>[
          CustomPaint(
            painter: basePainter,
            size: Size.infinite,
          ),
          CustomPaint(
            painter: startStopPainter,
            size: Size.infinite,
          ),
          GestureDetector(
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                if (details.pointerCount == 1 && isinregion(startStopPainter, details.localFocalPoint,true)){
                  startFlag = true;
                }
                if (details.pointerCount == 1 && isinregion(startStopPainter, details.localFocalPoint,false) && startFlag){
                  filenameController.text ='${DateTime.now().toString()}${basePainter.name}.json';
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Aufgabe abgeschlossen'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('Die Aufgabe wird unter folgenden Namen Abgespeichert:'),
                            TextFormField(
                              controller: filenameController,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () async{
                              StoreObject storageObject = StoreObject(offsets:offsets,timestamps:time,filename:filenameController.text,type:basePainter.name,date:time[0],abweichungen: basePainter.abweichungen(offsets),vorlagen: basePainter.offsets,tabScore: noLine.length);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aufzeichnung wurde gespeichert unter ${filenameController.text}'),));
                              await storage.writeFile(storageObject);
                              final TrendsMemory memory = await storage.readTrendsMemoryFileSingle(basePainter.name);
                              memory.offsetScores.add(storageObject.offsetScore);
                              memory.timeScores.add(storageObject.timeScore);
                              memory.tabScores.add(storageObject.tabScore);
                              memory.consistencyScores.add(storageObject.consistencyScore);
                              memory.type = storageObject.type;
                              await storage.writeTrendsMemoryFile(memory, basePainter.name);
                              offsets.clear();
                              time.clear();
                              noLine.clear();
                              startFlag = false;
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Abbrechen'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                }
                if (details.pointerCount == 1 && startFlag){
                 offsets.add(details.localFocalPoint);
                 time.add(DateTime.now());
                }
              });
            },
            onScaleStart: (ScaleStartDetails details) {
              setState(() {
                if (details.pointerCount == 1 && startFlag){
                  offsets.add(details.localFocalPoint);
                  time.add(DateTime.now());
                }
              });
            },
            onScaleEnd: (ScaleEndDetails details) {
              setState(() {
                noLine.add(offsets.length);
              });
            },
            child: CustomPaint(
              painter: Draw(offsets: offsets, noLine: noLine),
              size: Size.infinite,
            ),
          ),
          
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.clear),
        label: const Text('Neuer Versuch'),
        onPressed: () {
          setState(() => offsets.clear());
          startFlag = false;
        },
      ),
    );
  }
}



class Draw extends CustomPainter {
  Draw({required this.offsets, required this.noLine});

  final List<Offset> offsets;
  final List<int> noLine;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue.shade900;
    paint.strokeWidth = 5.0;


    for (int i = 0; i < offsets.length - 1; i++) {
      if (! noLine.contains(i+1)) {
        canvas.drawLine(offsets[i], offsets[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Draw oldDelegate) => true;
}

class StartStop extends PatternPainter {
  StartStop({required this.basePainter});

  final PatternPainter basePainter;
  double width = 0;
  double height = 0;

  @override
  void paint(Canvas canvas, Size size) {
    start = basePainter.start;
    stop = basePainter.stop;
    
    width = size.width/10;
    height = size.height/10;
    if (width > height){
      width = height; 
    }else{
      height = width;
    }
    Paint paint = Paint();
    paint.color = Colors.green.shade900;
    paint.color = paint.color.withOpacity(0.5);
    canvas.drawRect(Rect.fromCenter(center: start, width: width, height: height), paint);
    paint.color = Colors.red.shade900;
    paint.color = paint.color.withOpacity(0.5);
    canvas.drawRect(Rect.fromCenter(center: stop, width: width, height: height), paint);
  }

  @override
  bool shouldRepaint(StartStop oldDelegate) => true;
}
