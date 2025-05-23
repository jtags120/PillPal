// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

part 'nav.dart';
part 'home.dart';
part 'medList.dart';
part 'medCheck.dart';
part 'schedule.dart';
part 'checkMedication.dart';

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

    
    date = now;
    notifyListeners();
  }

  /// Add a named medication for any day
  void addTakenMedication(DateTime date, String name, bool taken, String time) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  if (!takenMedications.containsKey(normalizedDate)) {
    takenMedications[normalizedDate] = [];
  }
  takenMedications[normalizedDate]!.add(
    MedicationEntry(name: name, taken: taken, time: time),
  );
  notifyListeners();
}

}

/// Medication model
class MedicationEntry {
  final String name;
  final bool taken;
  final String time;

  MedicationEntry({required this.name, required this.time, required this.taken});
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ScheduleDialog(),
          );
        },
        child: Text("View or Change schedule"),
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

  final List<String> times = [];
  final Map<String, List<String>> medsByTime = {};
  final Map<String, TextEditingController> medControllers = {};

  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    seen = context.read<AppState>().seenWelcome;
  }

  void addTime() {
    final time = timeController.text.trim();
    if (time.isNotEmpty && !times.contains(time)) {
      setState(() {
        times.add(time);
        medsByTime[time] = [];
        medControllers[time] =
            TextEditingController(); // separate controller for each time
      });
      timeController.clear();
    }
  }

  void addMedication(String time) {
    final controller = medControllers[time];
    final med = controller?.text.trim() ?? "";
    if (med.isNotEmpty) {
      setState(() {
        medsByTime[time]?.add(med);
        controller?.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("👋 Welcome to PillPal!", style: TextStyle(fontSize: 20)),
            SizedBox(height: 12),
            Text("Let’s get started by setting up your medication schedule."),
            SizedBox(height: 16),

            // Time Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: "Add a time (e.g., Morning, 8:00 AM)",
                    ),
                    onSubmitted: (_) => addTime(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addTime,
                )
              ],
            ),
            SizedBox(height: 16),

            // Medication Inputs for Each Time
            for (String time in times)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Medications for $time",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: medControllers[time],
                          decoration: InputDecoration(
                              labelText: "Enter medication name"
                              ),
                            onSubmitted: (_) => addMedication(time),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => addMedication(time),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    children: medsByTime[time]!
                        .map((med) => Chip(label: Text(med)))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                ],
              ),

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AppState>().seenWelcome = true;
                for(String time in times){
                  for(String med in medsByTime[time]!){
                    context.read<AppState>().addTakenMedication(DateTime.now(), med, false, time);

                  }
                }
                Navigator.pop(context);
              },
              child: Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
