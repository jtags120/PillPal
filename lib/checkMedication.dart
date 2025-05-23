// ignore_for_file: use_key_in_widget_constructors

part of 'main.dart';

class CheckMedicationDialog extends StatefulWidget {
  @override
  State<CheckMedicationDialog> createState() => _CheckMedicationDialogState();
}

class _CheckMedicationDialogState extends State<CheckMedicationDialog> {
  Map<String, List<String>> medsByTime = {};
  String? currentTimeKey;
  List<String> medsToTake = [];
  Map<String, bool> checked = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentMeds();
  }

  void _loadCurrentMeds() {
    final appState = context.read<AppState>();

    // Use today's meds schedule (if medsByTime is stored somewhere)
    // Here, assuming appState has takenMedications with time strings
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    // Map of time -> meds for today
    medsByTime = {};

    if (appState.takenMedications.containsKey(normalizedDate)) {
      for (var entry in appState.takenMedications[normalizedDate]!) {
        medsByTime.putIfAbsent(entry.time, () => []).add(entry.name);
      }
    }

    if (medsByTime.isEmpty) {
      // No meds scheduled for today
      currentTimeKey = null;
      medsToTake = [];
      return;
    }

    // Parse keys as DateTimes today for sorting and comparison
    final now = DateTime.now();

    DateTime? parseTime(String timeStr) {
      try {
        // Try parsing 12-hour format like "8:00 AM"
        return DateFormat.jm().parseLoose(timeStr);
      } catch (e) {
        try {
          // Try 24-hour "HH:mm"
          return DateFormat.Hm().parseLoose(timeStr);
        } catch (_) {
          return null;
        }
      }
    }

    // Convert keys to DateTime with today’s date for comparison
    List<MapEntry<String, DateTime>> parsedTimes = [];

    medsByTime.forEach((timeStr, meds) {
      final parsed = parseTime(timeStr);
      if (parsed != null) {
        // Combine parsed time with today's date
        final combined = DateTime(
          now.year,
          now.month,
          now.day,
          parsed.hour,
          parsed.minute,
        );
        parsedTimes.add(MapEntry(timeStr, combined));
      }
    });

    // Find the most recent time before or equal to now
    parsedTimes.sort((a, b) => a.value.compareTo(b.value));

    String? chosenKey;

    for (var entry in parsedTimes) {
      if (entry.value.isBefore(now) || entry.value.isAtSameMomentAs(now)) {
        chosenKey = entry.key;
      }
    }

    if (chosenKey == null && parsedTimes.isNotEmpty) {
      // If no past time found, pick earliest future time (e.g., meds for tomorrow)
      chosenKey = parsedTimes.first.key;
    }

    currentTimeKey = chosenKey;
    medsToTake = currentTimeKey != null ? medsByTime[currentTimeKey]! : [];
    checked = {for (var med in medsToTake) med: false};

    setState(() {});
  }

  void _toggleChecked(String med) {
    setState(() {
      checked[med] = !(checked[med] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentTimeKey == null) {
      return AlertDialog(
        title: Text("No Medications Scheduled"),
        content: Text("You have no medications scheduled for right now."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text("Medications for $currentTimeKey"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: medsToTake.map((med) {
            return CheckboxListTile(
              title: Text(med),
              value: checked[med] ?? false,
              onChanged: (_) => _toggleChecked(med),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}
