// ignore_for_file: use_key_in_widget_constructors

part of 'main.dart';

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
        }),
      ],
    );
  }
}