import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'main.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({Key? key}) : super(key: key);

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  var _habitController = TextEditingController();
  var _dateController = TextEditingController();
  String selectedPriority = 'High';
  var _selectedFrequencyValue;
  var _frequencyDropdownList = <DropdownMenuItem>[];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _habitController,
                decoration: InputDecoration(
                  labelText: 'Habit',
                  hintText: 'Write Habit',
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Pick a Date',
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
                hint: Text('Frequency'),
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
                  _save();
                },
                child: Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    print('---------------> Habit: $_habitController.text');
    print('---------------> Priority: $selectedPriority');
    print('---------------> Date: $_dateController.text');
    print('---------------> Frequency: $_selectedFrequencyValue');

    Map<String, dynamic> row = {
      DatabaseHelper.columnHabit: _habitController.text,
      DatabaseHelper.columnPriority: selectedPriority,
      DatabaseHelper.columnDate: _dateController.text,
      DatabaseHelper.columnFrequency: _selectedFrequencyValue,
    };

    final result = await dbHelper.insert(row, DatabaseHelper.habitsTable);

    debugPrint('-----------------> inserted row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved.');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
