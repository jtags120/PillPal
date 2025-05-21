// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
        title: 'Pill Pal',
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
  DateTime? date;
  DateTime? inputDate;
  bool status = false;
  bool seenWelcome = false;

  // New structure to track meds per day
  Map<DateTime, List<MedicationEntry>> takenMedications = {};

  /// Mark the welcome dialog as seen
  void markWelcomeSeen() {
    seenWelcome = true;
    notifyListeners();
  }

  /// Used by MedCheck to store single status for today
  void addDate() {
    final now = DateTime.now();
    final normalizedDate = DateTime(now.year, now.month, now.day);
    
    if (!takenMedications.containsKey(normalizedDate)) {
      takenMedications[normalizedDate] = [];
    }

    // Record a generic medication status for the day
    takenMedications[normalizedDate]!.add(
      MedicationEntry(name: "Medication taken?", taken: status),
    );

    date = now;
    notifyListeners();
  }

  /// Add a named medication for any day
  void addMedication(DateTime date, String name, bool taken) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!takenMedications.containsKey(normalizedDate)) {
      takenMedications[normalizedDate] = [];
    }
    takenMedications[normalizedDate]!.add(MedicationEntry(name: name, taken: taken));
    notifyListeners();
  }
}

/// Medication model
class MedicationEntry {
  final String name;
  final bool taken;

  MedicationEntry({required this.name, required this.taken});
}


class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seenWelcome = context.read<AppState>().seenWelcome;
      if (!seenWelcome) {
        showDialog(
          context: context,
          builder: (_) => WelcomeDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
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
                    icon: Icon(Icons.home), label: ('Home')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: 'Med Regimen'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings')
              ]),
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
    final takenMedications = context.watch<AppState>().takenMedications;
    final sortedDates = takenMedications.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text("Medication Regimen", style: TextStyle(fontSize: 30)),
          ),
        ),
        ...sortedDates.map((date) {
          final formattedDate = DateFormat('yMMMd').format(date);
          final meds = takenMedications[date]!;

          return ExpansionTile(
            title: Text(formattedDate),
            children: meds.map((med) {
              return ListTile(
                leading: Icon(med.taken ? Icons.check : Icons.close,
                    color: med.taken ? Colors.green : Colors.red),
                title: Text(med.name),
                subtitle: Text(med.taken ? "Taken" : "Not Taken"),
              );
            }).toList(),
          );
        }).toList(),
      ],
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
              child: Text(
                "Have you taken your meds today?",
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                context.read<AppState>().status = true;
                context.read<AppState>().addDate();
                Navigator.pop(context);
              },
              child: Text('Yes', style: TextStyle(fontSize: 30)),
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
              child: Text('No', style: TextStyle(fontSize: 30)),
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
      child: ElevatedButton(
        onPressed: () {
          final now = DateTime.now();
          context.read<AppState>().addMedication(now, "Vitamin D", true);
          context.read<AppState>().addMedication(now, "Aspirin", false);
        },
        child: Text("Simulate Adding Meds"),
      ),
    );
  }
}

class WelcomeDialog extends StatefulWidget {
  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  late bool seen;

  @override
  void initState() {
    super.initState();
    seen = context.read<AppState>().seenWelcome;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(children: [
      Text("Welcome to PillPal!"),
      ElevatedButton(
        onPressed: () {
          context.read<AppState>().seenWelcome = true;
          Navigator.pop(context);
        },
        child: Text("Click this button to dismiss this message!"),
      )
    ]));
  }
}
