import 'package:flutter/material.dart';
import 'package:tremor_detection/storage.dart';
import 'package:tremor_detection/auswertung.dart';


class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() =>
      _ReviewState();
}

class _ReviewState extends State<Review> {
  final Storage storage = Storage();
  late Future<List<StoreObject>> fetchData;
  late List<int> items; 


  @override
  void initState() {
    super.initState();
    fetchData = storage.readFiles().whenComplete(() => null); // Replace with your data fetching logic
  }

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey<String>('bottom-sliver-list');
    return Scaffold(
      body: FutureBuilder(
        future: fetchData,
        builder: (context, AsyncSnapshot<List<StoreObject>> snapshot) {
          return CustomScrollView(
          center: centerKey,
          slivers: <Widget>[
            const SliverAppBar(
              key:centerKey,
              floating: true,
              title: Text('Ergebnisse'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if(snapshot.hasData){
                    final snapshotData = snapshot.data!;
                    final itemCount = snapshotData[index].timestamps.length;
                    items = List<int>.generate(itemCount, (int index) => index);
                    if(itemCount > 0){
                      return Dismissible(
                        key: UniqueKey(),//ValueKey<int>(items[index]),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                            ),
                            onDismissed: (DismissDirection direction) {
                              storage.delete(snapshotData[index].filename);
                              snapshot.data!.removeAt(index);
                              setState(() {
                                items.removeAt(index);
                              });
                            },
                        child: Row(
                        children: [
                          Image.asset("images/${snapshotData[index].type}.png",height:50),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Auswertung(data: snapshotData[index])),
                              );
                            },
                            child: Column(
                              children: [
                                Text('${[snapshotData[index].filename]}'),
                                //Text('${[snapshotData[index].timestamps[0].toString()]}'),
                              ],
                            ),
                          ),
                          const Icon(Icons.delete),
                        ],
                      ),
                      );
                    }else { return const Icon(Icons.loop);}
                  } else {return const Icon(Icons.loop);}
                },
                childCount: snapshot.data?.length,
              ),
            ),
          ],
        );
        },
      ),
    );
  }
}
