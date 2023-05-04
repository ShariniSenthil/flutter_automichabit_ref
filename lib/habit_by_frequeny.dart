import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_automichabit_ref/database_helper.dart';
import 'drawer_navigation.dart';
import 'habit.dart';
import 'main.dart';

class HabitByFrequency extends StatefulWidget {
  String frequency;

  HabitByFrequency({Key? key, required this.frequency}) : super(key: key);

  @override
  State<HabitByFrequency> createState() => _HabitByFrequencyState();
}

class _HabitByFrequencyState extends State<HabitByFrequency> {
  late List<Habit> _habitList;

  @override
  initState() {
    super.initState();
    getHabitByCategories();
  }

  getHabitByCategories() async {
    _habitList = <Habit>[];

    print('----------> Received Frequency:');

    print(this.widget.frequency);

    var habits = await dbHelper.readDataByColumnName(DatabaseHelper.habitsTable, DatabaseHelper.columnFrequency, this.widget.frequency);

    habits.forEach((habit) {
      setState(() {
        print(habit['_id']);
        print(habit['habit']);
        print(habit['priority']);
        print(habit['date']);
        print(habit['frequency']);

        var habitModel = Habit(habit['_id'], habit['habit'], habit['priority'],habit['date'], habit['frequency']);

        _habitList.add(habitModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Habit - Frequency List',
        ),
      ),
      drawer: DrawerNavigation(),
      body: ListView.builder(
          itemCount: _habitList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                child: ListTile(
                  onTap: () {
                    print(_habitList[index].id);
                    print(_habitList[index].habit);
                    print(_habitList[index].priority);
                    print(_habitList[index].date);
                    print(_habitList[index].frequency);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_habitList[index].habit ?? 'No Data'),
                    ],
                  ),
                  subtitle: Text(_habitList[index].frequency ?? 'No Data'),
                  trailing: Text(_habitList[index].date ?? 'No Data'),
                ),
              ),
            );
          }),
    );
  }
}