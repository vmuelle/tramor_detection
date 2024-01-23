import 'package:collection/collection.dart';
import 'package:tremor_detection/storage.dart';
import 'package:flutter/material.dart';

class Means{
  final String type;
  final double mean;
  final double lastMean;
  final int count;

  const Means({required this.type, required this.mean, required this.lastMean, required this.count});
}



class Trends extends StatefulWidget {
  const Trends({super.key});

  @override
  State<Trends> createState() =>
      _TrendsState();
}

class _TrendsState extends State<Trends> {
  final Storage storage = Storage();

  List<Means> offsetScores = <Means>[];
  List<Means> timeScores = <Means>[];
  List<Means> tabScores = <Means>[];
  List<Means> consistencyScores = <Means>[];

  late Future<List<TrendsMemory>> data;

  @override
  void initState() {
    super.initState();
    data = storage.readTrendsMemoryFiles().whenComplete(() => null); // Replace with your data fetching logic
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Auswertung"),
      ),
      body: FutureBuilder(
        future: data,
        builder: (context, AsyncSnapshot<List<TrendsMemory>> snapshot) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverList(delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if(snapshot.hasData){
                    calcMeans(snapshot.data!);
                    return Column(
                      children: <Widget>[
                        Text("Total: ${offsetScores.last.count}",style: const TextStyle(fontSize: 35),),
                        Container(
                          child: Row(
                            children: <Widget>[
                              getContainer(snapshot.data!.length),
                            ]
                          ),
                        ),
                      ],
                    );
                  } else { return const Icon(Icons.loop);}
                },
                childCount: 1, 
              )),
              SliverList(delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if(snapshot.hasData){
                    calcMeans(snapshot.data!);
                    return Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: Text("${offsetScores[index].type} : ${offsetScores[index].count}"), 
                          children: <Widget>[
                            Container(
                              child: getContainer(index),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else { return const Icon(Icons.loop);}
                },
                childCount: 5, 
              )),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
           child: const Text('Trends zurücksetzen'),
              onPressed:  ()async {
                data = storage.deleteTrendsMemory();
                setState(() {

                  data = storage.readTrendsMemoryFiles();
                });
            },
          ),
        ),
    );
  }

  void calcMeans(List<TrendsMemory> data){
    
    offsetScores = <Means>[];
    timeScores = <Means>[];
    tabScores = <Means>[];
    consistencyScores = <Means>[];
    for(int i = 0; i < data.length; i++){
      getMeanScores(data[i].offsetScores,data[i].type,"offset");
      getMeanScores(data[i].consistencyScores,data[i].type,"consistency");
      getMeanScores(data[i].timeScores,data[i].type,"time");
      getMeanScores(data[i].tabScores.map((i) => i.toDouble()).toList(),data[i].type,"tab");
    }
    offsetScores.add(Means(type:"total", mean:offsetScores.map((score) => score.mean).sum ,lastMean:offsetScores.map((score) => score.lastMean).sum,count: offsetScores.map((score) => score.count).sum));
    consistencyScores.add(Means(type:"total", mean:consistencyScores.map((score) => score.mean).sum ,lastMean:consistencyScores.map((score) => score.lastMean).sum,count: consistencyScores.map((score) => score.count).sum));
    timeScores.add(Means(type:"total", mean:timeScores.map((score) => score.mean).sum ,lastMean:timeScores.map((score) => score.lastMean).sum,count: timeScores.map((score) => score.count).sum));
    tabScores.add(Means(type:"total", mean:tabScores.map((score) => score.mean).sum ,lastMean:tabScores.map((score) => score.lastMean).sum,count: tabScores.map((score) => score.count).sum));
  }

  void getMeanScores(List<double> scores,String type, String meansType){
    double sumOfAll = scores.sum;
    double sumOfAllMinusLast;
    Means toAdd;
    try{
      sumOfAllMinusLast = sumOfAll - scores.slice(scores.length-6,scores.length-1).sum;
      double mean = sumOfAll/scores.length;
      double oldMean = sumOfAllMinusLast/(scores.length-5);
      toAdd = Means(type:type, mean:mean ,lastMean:oldMean,count: scores.length);
    } catch (e){
      sumOfAllMinusLast = sumOfAll;
      double mean = (sumOfAll/scores.length).isNaN ? 0 : sumOfAll/scores.length;
      double oldMean = mean;
      toAdd = Means(type:type, mean:mean ,lastMean:oldMean,count:scores.length);
    }
    
    
    switch (meansType){
      case "offset": offsetScores.add(toAdd);
      case "consistency": consistencyScores.add(toAdd);
      case "time": timeScores.add(toAdd);
      case "tab": tabScores.add(toAdd);
    }    
  }

  Widget getContainer(int index){
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              Column(children: <Widget> [
                const Text("Abweichung:"),
                Row( children: <Widget>[
                  Text(offsetScores[index].lastMean.toStringAsFixed(2)),
                  Icon( offsetScores[index].lastMean > offsetScores[index].mean ? Icons.arrow_upward : Icons.arrow_downward,
                    color: offsetScores[index].lastMean > offsetScores[index].mean ? Colors.green : Colors.red),
                  Text(offsetScores[index].mean.toStringAsFixed(2)),
                ],),
              ],),
              Column(children: <Widget> [
                const Text("Zeit:"),
                Row(
                  children: <Widget>[
                    Text(timeScores[index].lastMean.toStringAsFixed(2)),
                    Icon( timeScores[index].lastMean > timeScores[index].mean ? Icons.arrow_upward : Icons.arrow_downward,
                          color: timeScores[index].lastMean > timeScores[index].mean ? Colors.green : Colors.red),
                    Text(timeScores[index].mean.toStringAsFixed(2)),
                  ]
                ),
              ],),
              Column(children: <Widget> [
                const Text("Tabs:"),
                Row(
                  children: <Widget>[
                    Text(tabScores[index].lastMean.toStringAsFixed(2)),
                    Icon( tabScores[index].lastMean > tabScores[index].mean ? Icons.arrow_upward : Icons.arrow_downward,
                          color: tabScores[index].lastMean > tabScores[index].mean ? Colors.green : Colors.red),
                    Text(tabScores[index].mean.toStringAsFixed(2)),
                  ]
                ),
              ],),
              Column(children: <Widget> [
                const Text("Consistency:"),
                Row(
                  children: <Widget>[
                    Text(consistencyScores[index].lastMean.toStringAsFixed(2)),
                    Icon( consistencyScores[index].lastMean > consistencyScores[index].mean ? Icons.arrow_upward : Icons.arrow_downward,
                          color: consistencyScores[index].lastMean > consistencyScores[index].mean ? Colors.green : Colors.red),
                    Text(consistencyScores[index].mean.toStringAsFixed(2),style: const TextStyle(fontSize: 20),),
                  ]
                ),
              ],),
            ]
          ),
        ),
      ],
    );
  }
}

//class TrendsContainer(TrendsMemory mem) extends ExpansionTile{}


  
