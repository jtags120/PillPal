// ignore_for_file: use_key_in_widget_constructors

part of 'main.dart';

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