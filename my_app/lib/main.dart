import 'package:flutter/material.dart';
import 'providers/contact_provider.dart';
import 'screens/contact_list_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ContactManagerApp());
}

class ContactManagerApp extends StatefulWidget {
  const ContactManagerApp({super.key});

  @override
  State<ContactManagerApp> createState() => _ContactManagerAppState();
}

class _ContactManagerAppState extends State<ContactManagerApp> {
  late final ContactProvider _contactProvider;

  @override
  void initState() {
    super.initState();
    _contactProvider = ContactProvider();
  }

  @override
  void dispose() {
    _contactProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _contactProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Contact Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _contactProvider.themeMode,
          home: ContactListScreen(provider: _contactProvider),
        );
      },
    );
  }
}
