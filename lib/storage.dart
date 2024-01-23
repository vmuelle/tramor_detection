import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'dart:math';


class TrendsMemory{
  List<double> offsetScores;
  List<int> tabScores;
  List<double> timeScores;
  List<double> consistencyScores;
  String type;

  TrendsMemory({
    required this.offsetScores,
    required this.tabScores,
    required this.timeScores,
    required this.consistencyScores,
    required this.type,});

  Map<String, dynamic> toJson() {
    return {
      'offsetScores': offsetScores.toList(),
      'tabScores': tabScores.toList(),
      'timeScores': timeScores.toList(),
      'consistencyScores': consistencyScores.toList(),
      'type': type,
    };
  }
  factory TrendsMemory.fromJson(Map<String, dynamic> json) {
    return TrendsMemory(
      offsetScores: (json['offsetScores'] as List).map((offset) => double.parse('$offset')).toList(),
      tabScores: (json['tabScores'] as List).map((offset) => double.parse('$offset').round()).toList(),
      timeScores: (json['timeScores'] as List).map((offset) => double.parse('$offset')).toList(),
      consistencyScores: (json['consistencyScores'] as List).map((offset) => double.parse('$offset')).toList(),
      type: json['type'],
    );
  }

  factory TrendsMemory.fromEmpty(String name){
      return TrendsMemory(offsetScores: <double>[], tabScores: <int>[], timeScores: <double>[], consistencyScores: <double>[], type: name);
  }
}


class StoreObject{
  List<Offset> offsets;
  List<Offset> vorlagen;
  List<DateTime> timestamps;
  List<double> abweichungen;
  String filename;
  String type;
  DateTime date;
  double offsetScore = 0;
  double timeScore = 0;
  int tabScore;
  double consistencyScore = 0;
  double minY = 0;
  double maxY = 0;

  StoreObject({required this.offsets,
    required this.timestamps,
    required this.filename,
    required this.type,
    required this.date,
    required this.abweichungen,
    required this.vorlagen,
    required this.tabScore,});


  Future<Map<String, dynamic>> toJson () async {
    offsetScore =  abweichungen.average;
    timeScore = getTimeScoreStd();
    consistencyScore = getNumLocalMaximumMinimum()/abweichungen.length;
    final double minVorlage = vorlagen.reduce((min, offset) => min.dy < offset.dy ? min : offset).dy;
    final double maxVorlage = vorlagen.reduce((max, offset) => max.dy > offset.dy ? max : offset).dy;

    final double minOffset = offsets.reduce((min, offset) => min.dy < offset.dy ? min : offset).dy;
    final double maxOffset = offsets.reduce((max, offset) => max.dy > offset.dy ? max : offset).dy;

    minY = minVorlage<minOffset ? minVorlage : minOffset;
    maxY = maxVorlage>maxOffset ? maxVorlage : maxOffset;

    List<Offset> offsetsNeu = <Offset>[];
    List<Offset> vorlagenNeu = <Offset>[];
    for (int i = 0; i < offsets.length; i++){
        offsetsNeu.add(Offset(offsets[i].dx, offsets[i].dy-minY+50));
    }
    for (int i = 0; i < vorlagen.length; i++){
        vorlagenNeu.add( Offset(vorlagen[i].dx, vorlagen[i].dy-minY+50));
    }

    return {
      'offsets': offsetsNeu.map((offset) => [offset.dx, offset.dy]).toList(),
      'vorlagen': vorlagenNeu.map((vorlage) => [vorlage.dx, vorlage.dy]).toList(),
      'timestamps': timestamps.map((timestamp) => timestamp.toIso8601String()).toList(),
      'abweichungen': abweichungen.toList(),
      'filename': filename,
      'type': type,
      'date': date.toIso8601String(),
      'offsetScore': offsetScore,
      'timeScore': timeScore,
      'tabScore': tabScore,
      'consistencyScore': consistencyScore,
      'minY': minY,
      'maxY': maxY,
    };
  }

  factory StoreObject.fromJson(Map<String, dynamic> json) {
    StoreObject object = StoreObject(
      offsets: (json['offsets'] as List).map((offset) => Offset(offset[0], offset[1])).toList(),
      vorlagen: (json['vorlagen'] as List).map((offset) => Offset(offset[0], offset[1])).toList(),
      timestamps: (json['timestamps'] as List).map((timestamp) => DateTime.parse(timestamp)).toList(),
      filename: json['filename'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      abweichungen: (json['abweichungen'] as List).map((abweichungen) => double.parse('$abweichungen')).toList(),
      tabScore: json['tabScore'],
    );
    object.offsetScore = json['offsetScore'];
    object.timeScore = json['timeScore'];
    object.consistencyScore = json['consistencyScore'];
    object.minY = json['minY'];
    object.maxY = json['maxY'];
    return object;
  }

  int getNumLocalMaximumMinimum(){
    int total = 0;
    for (int i = 1; i < abweichungen.length-1; i++){
        if(abweichungen[i-1] < abweichungen[i] && abweichungen[i+1] < abweichungen[i]){
          total++;
        }
        if(abweichungen[i-1] > abweichungen[i] && abweichungen[i+1] > abweichungen[i]){
          total++;
        }
    }
    return total;
  }

  double getTimeScoreStd(){
    var durationList = <double>[];
    
    for(int i = 2; i<timestamps.length;i++){
      final duration =timestamps[i].difference(timestamps[i-1]).inMilliseconds.toDouble();
      durationList.add(duration);
    }
    double mean = durationList.average;
    for (int i = 0; i < durationList.length;i++){
      durationList[i] = durationList[i]-mean;
      durationList[i] = durationList[i]*durationList[i];
    }

    final variance = durationList.sum / durationList.length;
    return sqrt(variance);
  }
}


class Storage {

 

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> _getLocalDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final mydir =  Directory('${directory.path}/DataDirectory');
     if (!await mydir.exists()) {
      await mydir.create();
    }
    return mydir;
  }

  Future<int> readFile(String filename) async {
    try {
      final path = await _localPath;
      final file = File('$path/$filename');
      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<TrendsMemory> readTrendsMemoryFileSingle(String name) async {
    try {
      final path = await _localPath;
      final file = File('$path/$name-trends.json');
      final contents = await file.readAsString();
      final Map<String, dynamic> jsonMap = json.decode(contents);
      return TrendsMemory.fromJson(jsonMap);
      
    } catch (e) {
      // If encountering an error, return 0
      return TrendsMemory.fromEmpty(name);
    }
  }

  Future<List<TrendsMemory>> readTrendsMemoryFiles() async {
    try {
      List<TrendsMemory> fileList = <TrendsMemory>[];
      final path = await _localPath;
      final names = ["line","sinus","ramp","pulse","spirale"];
      for (final name in names){
        try{
        final file = File('$path/$name-trends.json');
        final contents = await file.readAsString();
        final Map<String, dynamic> jsonMap = json.decode(contents);
        fileList.add(TrendsMemory.fromJson(jsonMap));
        }catch(e) {
          fileList.add(TrendsMemory.fromEmpty(name));
        }
      }
      return fileList;
    } catch (e) {
      // If encountering an error, return 0
      return <TrendsMemory>[];
    }
  }


  Future<List<TrendsMemory>> deleteTrendsMemory() async {
    List<TrendsMemory> fileList = <TrendsMemory>[];
    try{
      final path = await _localPath;
      final names = ["line","sinus","ramp","pulse","spirale"];
      for (final name in names){
        final file = File('$path/$name-trends.json');
        await file.delete();
        await File('$path/$name-trends.json').create();
        fileList.add(TrendsMemory.fromEmpty(name));
      }
    } catch (e) {
      // If encountering an error, return 0
    }
    return fileList;
  }

  Future<List<StoreObject>> readFiles() async {
    try {
      List<StoreObject> fileList = <StoreObject>[];
      final directory = await getApplicationDocumentsDirectory();
      List<FileSystemEntity> files = await directory.list().toList();
      for (FileSystemEntity file in files) {
          if(file is File){
            try{
              final jsonString = await file.readAsString();
              final Map<String, dynamic> jsonMap = json.decode(jsonString);
              fileList.add(StoreObject.fromJson(jsonMap));
            } catch(e){
              print(e);
            }
          }
      }
      fileList.sort((a,b) => b.date.compareTo(a.date));
      return fileList;
    } catch (e) {
      // If encountering an error, return 0
      return <StoreObject>[];
    }
  }


  Future<List<FileSystemEntity>> readDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.list().toList();
  }


  Future<File> writeFile(StoreObject toWrite) async {
    final path = await _localPath;
    final filename = toWrite.filename;
    final file = File('$path/$filename');
    final json = jsonEncode(await toWrite.toJson());
    return await file.writeAsString(json);
  }

  Future<File> writeTrendsMemoryFile(TrendsMemory toWrite,String name) async {
    final path = await _localPath;
    final file = File('$path/$name-trends.json');
    final json = jsonEncode(toWrite.toJson());
    return file.writeAsString(json);
  }


  Future<void> delete(String filename) async{
    final path = await _localPath;
    final file = File('$path/$filename');
    file.delete();
  }
}





