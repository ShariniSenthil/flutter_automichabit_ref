import 'package:flutter/material.dart';
import 'package:flutter_automichabit_ref/frequency_screen.dart';
import 'database_helper.dart';
import 'habit_by_frequeny.dart';
import 'home_screen.dart';
import 'main.dart';

class DrawerNavigation extends StatefulWidget {

  const DrawerNavigation({Key? key}) : super(key: key);

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  List<Widget> _frequencyList = <Widget>[];

  @override
  initState(){
    super.initState();
    getAllFrequency();
  }

  getAllFrequency() async {
    var frequencies = await dbHelper.queryAllRows(DatabaseHelper.frequencyTable);

    frequencies.forEach((frequency) {
      setState(() {
        _frequencyList.add(InkWell(
          onTap: (){
            print('----------> Selected Category:');
            print(frequency['_id']);
            print(frequency['frequency']);

            Navigator.push(
              context, new MaterialPageRoute(
                builder: (context) => new HabitByFrequency(frequency: frequency['frequency'],)),
            );
          },
          child: ListTile(
            title: Text(frequency['frequency']),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Atomic Habits'),
              accountEmail: Text('sharinisenthil00@gmail.com'),
              currentAccountPicture: CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('images/lotus_images.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
              ),
              title: Text(
                'Home',
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.view_list,
              ),
              title: Text(
                'Frequency',
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FrequencyScreen()));
              },
            ),
            Divider(),
            Column(
              children: _frequencyList,
            )
          ],
        ),
      ),
    );
  }
}
