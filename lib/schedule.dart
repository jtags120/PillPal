// ignore_for_file: use_key_in_widget_constructors

part of 'main.dart';

class ScheduleDialog extends StatefulWidget {
  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  bool isEditing = false;

  final TextEditingController timeController = TextEditingController();
  final TextEditingController medController = TextEditingController();

  Map<String, List<String>> medsByTime = {};

  @override
  void initState() {
    super.initState();
    _loadMedsFromAppState();
  }

  void _loadMedsFromAppState() {
    final appState = context.read<AppState>();
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    medsByTime.clear();

    if (appState.takenMedications.containsKey(normalizedDate)) {
      for (var entry in appState.takenMedications[normalizedDate]!) {
        if (entry.name != "Medication taken?") {
          medsByTime.putIfAbsent(entry.time, () => []).add(entry.name);
        }
      }
    }
  }

  void _saveToAppState() {
    final appState = context.read<AppState>();
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    appState.takenMedications[normalizedDate] = [];

    medsByTime.forEach((time, meds) {
      for (var med in meds) {
        appState.addTakenMedication(normalizedDate, med, false, time);
      }
    });
  }

  void _addMedication() {
    final time = timeController.text.trim();
    final med = medController.text.trim();

    if (time.isNotEmpty && med.isNotEmpty) {
      setState(() {
        medsByTime.putIfAbsent(time, () => []).add(med);
      });
      timeController.clear();
      medController.clear();
    }
  }

  void _removeMedication(String time, String med) {
    setState(() {
      medsByTime[time]?.remove(med);
      if (medsByTime[time]?.isEmpty ?? false) {
        medsByTime.remove(time);
      }
    });
  }

  void _changeMedicationTime(String oldTime, String med, String newTime) {
    setState(() {
      medsByTime[oldTime]?.remove(med);
      if (medsByTime[oldTime]?.isEmpty ?? false) {
        medsByTime.remove(oldTime);
      }

      medsByTime.putIfAbsent(newTime, () => []).add(med);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedTimes = medsByTime.keys.toList()..sort();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Medication Schedule",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (isEditing) _saveToAppState();
                    setState(() => isEditing = !isEditing);
                  },
                ),
              ],
            ),
            SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var time in sortedTimes)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(time,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...medsByTime[time]!.map((med) {
                            return ListTile(
                              title: Text(med),
                              trailing: isEditing
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.schedule),
                                          onPressed: () {
                                            final editTimeController =
                                                TextEditingController(
                                                    text: time);
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text("Change Time"),
                                                content: TextField(
                                                  controller:
                                                      editTimeController,
                                                  decoration: InputDecoration(
                                                      labelText: "New time"),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      final newTime =
                                                          editTimeController
                                                              .text
                                                              .trim();
                                                      if (newTime.isNotEmpty) {
                                                        _changeMedicationTime(
                                                            time, med, newTime);
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Text("Update"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () =>
                                              _removeMedication(time, med),
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          }),
                          Divider(),
                        ],
                      ),
                    if (isEditing)
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (pickedTime != null) {
                                final formattedTime =
                                    pickedTime.format(context);
                                setState(() {
                                  timeController.text =
                                      formattedTime; // update controller so UI shows selection
                                });
                              }
                            },
                            child: Text(
                              timeController.text.isEmpty
                                  ? 'Pick Time'
                                  : 'Time: ${timeController.text}',
                            ),
                          ),
                          TextField(
                            controller: medController,
                            decoration:
                                InputDecoration(labelText: "Medication Name"),
                            onSubmitted: (_) => _addMedication(),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _addMedication,
                            child: Text("Add Medication"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            )
          ],
        ),
      ),
    );
  }
}
