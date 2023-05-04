import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'habit.dart';
import 'main.dart';

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({Key? key}) : super(key: key);

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  var _habitController = TextEditingController();
  var _dateController = TextEditingController();
  String selectedPriority = 'High';
  var _selectedFrequencyValue;
  var _frequencyDropdownList = <DropdownMenuItem>[];
  // edit only
  bool firstTimeFlag = false;
  int _selectedId = 0;

  @override
  void initState(){
    super.initState();
    getAllFrequency();
  }

  getAllFrequency() async {

    var frequencies = await dbHelper.queryAllRows(DatabaseHelper.frequencyTable);

    frequencies.forEach((frequency) {
      setState(() {
        _frequencyDropdownList.add(
          DropdownMenuItem(
            child: Text(frequency['frequency']),
            value: frequency['frequency'],
          ),
        );
      });
    });
  }

  _deleteFormDialog(BuildContext context) {
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
                  final result = await dbHelper.delete(_selectedId, DatabaseHelper.habitsTable);

                  debugPrint('-----------------> Deleted Row Id: $result');

                  if(result >0 ) {
                    _showSuccessSnackBar(context, 'Deleted.');
                    Navigator.pop(context);
                  }
                },
                child: const Text('Delete'),
              )
            ],
            title: const Text('Are you sure you want to delete this?'),

          );
        });
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  DateTime _dateTime = DateTime.now();

  _showDatePicker(BuildContext context) async{
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));

    if(_pickedDate != null){
      setState(() {
        _dateTime = _pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(_pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // edit only
    if ( firstTimeFlag == false) {
      print('---------->once execute ');
      firstTimeFlag = true;
      final habit = ModalRoute
          .of(context)!
          .settings
          .arguments as Habit;
      print('---------->Received Data:');
      print(habit.id);
      print(habit.habit);
      print(habit.priority);
      print(habit.date);
      print(habit.frequency);

      _selectedId = habit.id!;
      _habitController.text = habit.habit;
      _dateController.text = habit.date;
      _selectedFrequencyValue = habit.frequency;

      // Radio Button
      if (habit.priority == "High") {
        selectedPriority = "High";
      } else {
        selectedPriority = "Low";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Habit'),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text("Delete")),
            ],
            elevation: 2,
            onSelected: (value) {
              if (value == 1) {
                _deleteFormDialog(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _habitController,
              decoration: InputDecoration(
                labelText: 'Habit',
              ),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: InkWell(
                    onTap: () {
                      _showDatePicker(context);
                    },
                    child: Icon(Icons.calendar_today),
                  )),
            ),
            DropdownButtonFormField(
              value: _selectedFrequencyValue,
              items: _frequencyDropdownList,
              onChanged: (value) {
                setState(() {
                  _selectedFrequencyValue = value;
                  print(_selectedFrequencyValue);
                });
              },
            ),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RadioListTile(
                  title: Text("High"),
                  value: "High",
                  groupValue: selectedPriority,
                  onChanged: (value){
                    setState(() {
                      selectedPriority = value as String;
                    });
                  },
                ),
                RadioListTile(
                  title: Text("Low"),
                  value: "Low",
                  groupValue: selectedPriority,
                  onChanged: (value){
                    setState(() {
                      selectedPriority = value as String;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () async {
                _update();
              },
              child: Text('Update'),
            )
          ],
        ),
      ),
    );
  }

  void _update() async {
    print('---------------> Habit: $_habitController.text');
    print('---------------> Priority: $selectedPriority');
    print('---------------> Date: $_dateController.text');
    print('---------------> Frequency: $_selectedFrequencyValue');

    Map<String, dynamic> row = {
      // edit only - columnId
      DatabaseHelper.columnId: _selectedId,
      DatabaseHelper.columnHabit: _habitController.text,
      DatabaseHelper.columnPriority: selectedPriority,
      DatabaseHelper.columnDate: _dateController.text,
      DatabaseHelper.columnFrequency: _selectedFrequencyValue,
    };

    final result = await dbHelper.update(row, DatabaseHelper.habitsTable);

    debugPrint('-----------------> Updated row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated.');
    }
  }
}
