// ignore_for_file: use_key_in_widget_constructors

part of 'main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Check Medication'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CheckMedicationDialog(),
          );
        },
      ),
    );
  }
}
