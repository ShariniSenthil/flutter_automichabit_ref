import 'package:flutter/material.dart';
import 'package:flutter_automichabit_ref/database_helper.dart';
import 'package:flutter_automichabit_ref/habit.dart';
import 'package:flutter_automichabit_ref/main.dart';
import 'drawer_navigation.dart';
import 'edit_habit_screen.dart';
import 'habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Habit> _habitList;

  @override
  initState() {
    super.initState();
    getAllHabit();
  }

  getAllHabit() async {
    _habitList = <Habit>[];

    var habits = await dbHelper.queryAllRows(DatabaseHelper.habitsTable);

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
          'Habit List',
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
                    print('---------->Edit or Delete invoked: Send Data');
                    print(_habitList[index].id);
                    print(_habitList[index].habit);
                    print(_habitList[index].priority);
                    print(_habitList[index].date);
                    print(_habitList[index].frequency);

                    Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => EditHabitScreen(),
                      settings: RouteSettings(
                        arguments: _habitList[index],
                      ),
                    ));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('---------->add invoked');
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HabitScreen()));
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}