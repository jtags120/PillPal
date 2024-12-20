// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Pill Pall',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: Navigation(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  DateTime? date ;
  DateTime? inputDate;
  bool status = false;
  var taken = {};
  bool seenWelcome = false;
  

  void addDate() {
    date = DateTime.now();
    if (status) {
      taken[date] = 'Yes';
    }
    else {
      taken[date] = 'No';
    }
    notifyListeners();
  }
}

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;

  @override
void initState(){
  super.initState();
  bool seen = context.read<AppState>().seenWelcome;
    if (seen) {
      showDialog(
        context: context,
        builder: (BuildContext context){
          return WelcomeDialog();
        }
      );
    }
  }

  @override
  Widget build(BuildContext context){
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = MedList();
      case 2:
        page = SettingsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: page,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: ('Home')
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Med Regimen'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings'
            )
          ]
        ),
          );
        }, 
      );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Check Medication'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedCheck()),
          );
        },
        ),
    );
  }
}



class MedList extends StatefulWidget {
  @override
  State<MedList> createState() => _MedListState();
}

class _MedListState extends State<MedList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text("Medication Regimen",
            style: TextStyle(fontSize: 30),),)
          ),
      for (var date in context.watch<AppState>().taken.keys)
        ListTile(
          leading: Icon(Icons.medication),
          title: Text('$date: ${context.watch<AppState>().taken[date]}'),
    )
    ]
    );
  }
}


class MedCheck extends StatefulWidget {
  @override
  State<MedCheck> createState() => _MedCheckState();
}

class _MedCheckState extends State<MedCheck> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(70.0), 
              child: Text("Have you taken your meds today?",
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,)
                      ,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                context.read<AppState>().status = true;
                context.read<AppState>().addDate();
                Navigator.pop(context);
              },
              child: Text('Yes',
              style: TextStyle(fontSize: 30)),
            ),


            SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                context.read<AppState>().status = false;
                context.read<AppState>().addDate();
                Navigator.pop(context);
              },
              child: Text('No',
              style: TextStyle(fontSize: 30)),
            ),

          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings'),
    );
  }
}


class WelcomeDialog extends StatefulWidget{
  @override
  State<WelcomeDialog> createState () => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {

  @override
  Widget build(BuildContext context){
    return Dialog(
      child:Column(
              children: [
                Text("Welcome to PillPal!"),
                ElevatedButton(
                  onPressed: () {
                    context.read<AppState>().seenWelcome = true;
                    Navigator.pop(context);
                  },
                  child: Text("I have know how the app works"),
                )
              ]
       )
    );
  }
}