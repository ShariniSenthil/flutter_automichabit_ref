import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'frequency.dart';
import 'main.dart';

class FrequencyScreen extends StatefulWidget {
  const FrequencyScreen({Key? key}) : super(key: key);

  @override
  State<FrequencyScreen> createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {
  var _frequencyController = TextEditingController();
  late List<Frequency> _frequencyList;

  @override
  initState() {
    super.initState();
    getAllFrequency();
  }

  getAllFrequency() async {
    _frequencyList = <Frequency>[];

    var frequencies = await dbHelper.queryAllRows(DatabaseHelper.frequencyTable);

    frequencies.forEach((frequency) {
      setState(() {
        print(frequency['_id']);
        print(frequency['frequency']);

        var frequencyModel = Frequency(frequency['_id'], frequency['frequency']);

        _frequencyList.add(frequencyModel);
      });
    });
  }

  _deleteFormDialog(BuildContext context, frequencyId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await dbHelper.delete(frequencyId, DatabaseHelper.frequencyTable);

                  debugPrint('-----------------> Deleted Row Id: $result');

                  if(result >0 ) {
                    _showSuccessSnackBar(context, 'Deleted.');
                    Navigator.pop(context);
                    getAllFrequency();
                  }
                },
                child: const Text('Delete'),
              )
            ],
            title: const Text('Are you sure you want to delete this?'),

          );
        });
  }

  _showFromDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,  //true-out side click dissmisses
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  print('---------->cancel invoked');
                  Navigator.pop(context);
                  _frequencyController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async{
                  print('---------->save invoked');
                  print('Frequency: ${_frequencyController.text}');
                  _save();
                },
                child: Text('Save'),
              )
            ],
            title: Text('Frequency'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                TextField(
                  controller: _frequencyController,
                  decoration: InputDecoration(
                    hintText: 'Enter Frequency',),
                ),
              ]),
            ),
          );
        });
  }

  _editCategory(BuildContext context, frequencyId) async{

    print(frequencyId);

    var row = await dbHelper.readDataById(DatabaseHelper.frequencyTable, frequencyId);

    setState(() {
      _frequencyController.text = row[0]['frequency']??'No Data';
    });

    _editFromDialog(context, frequencyId);

  }

  _editFromDialog(BuildContext context, frequencyId) {
    return showDialog(
        context: context,
        barrierDismissible: true,  //true-out side click dissmisses
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  print('---------->cancel invoked');
                  Navigator.pop(context);
                  _frequencyController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async{
                  print('---------->Update invoked');
                  print('Frequency: ${_frequencyController.text}');
                  _update(frequencyId);
                },
                child: Text('Update'),
              )
            ],
            title: Text('Frequency'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                TextField(
                  controller: _frequencyController,
                  decoration: InputDecoration(
                      hintText: 'Enter Frequency',),
                ),
              ]),
            ),
          );
        });
  }

  void _save() async {
    print('---------------> Frequency: $_frequencyController.text');

    Map<String, dynamic> row = {
      DatabaseHelper.columnFrequency: _frequencyController.text,
    };

    final result = await dbHelper.insert(row, DatabaseHelper.frequencyTable);

    debugPrint('-----------------> inserted row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      getAllFrequency();
      _showSuccessSnackBar(context, 'Saved.');
    }

    _frequencyController.clear();
  }

  void _update(int frequencyId) async {
    print('---------------> Frequency: $_frequencyController.text');
    print('---------------> Frequency id: $frequencyId');

    Map<String, dynamic> row = {
      DatabaseHelper.columnFrequency: _frequencyController.text,
      DatabaseHelper.columnId: frequencyId,
    };

    final result = await dbHelper.update(row, DatabaseHelper.frequencyTable);

    debugPrint('-----------------> Updated row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      getAllFrequency();
      _showSuccessSnackBar(context, 'Updated.');
    }

    _frequencyController.clear();
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequency',
        ),
      ),
      body: ListView.builder(
        itemCount: _frequencyList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: Card(
              elevation: 8.0,
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    print('---------------> Edit');
                    _editCategory(context, _frequencyList[index].id);
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_frequencyList[index].frequency),
                    IconButton(
                      onPressed: () {
                        print('---------------> Delete Invoked');
                        _deleteFormDialog(context, _frequencyList[index].id);
                      },
                      icon: Icon(Icons.delete, color: Colors.red,),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('---------->add invoked');
          _showFromDialog(context);
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
