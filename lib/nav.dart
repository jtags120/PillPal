// ignore_for_file: use_key_in_widget_constructors

part of 'main.dart';

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