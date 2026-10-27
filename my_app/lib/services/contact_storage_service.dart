import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

/// Storage service for persisting contacts and preferences.
class ContactStorageService {
  static const String _contactsKey = 'app_contacts_v1';
  static const String _themeKey = 'app_theme_mode';
  static const String _initializedKey = 'app_data_initialized';

  /// Fetch all saved contacts from local storage.
  /// If first launch, populates with realistic sample contacts.
  Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isInitialized = prefs.getBool(_initializedKey) ?? false;

    if (!isInitialized) {
      final sampleContacts = _getSampleContacts();
      await saveContacts(sampleContacts);
      await prefs.setBool(_initializedKey, true);
      return sampleContacts;
    }

    final rawJson = prefs.getString(_contactsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Contact.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // In case of corrupt storage, fallback safely
      return [];
    }
  }

  /// Save contacts list to persistent storage.
  Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(contacts.map((c) => c.toMap()).toList());
    await prefs.setString(_contactsKey, encoded);
  }

  /// Reset to sample contacts.
  Future<List<Contact>> resetToSamples() async {
    final sampleContacts = _getSampleContacts();
    await saveContacts(sampleContacts);
    return sampleContacts;
  }

  /// Clear all stored contacts.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contactsKey);
  }

  /// Load theme mode (true for dark, false for light, null for system).
  Future<bool?> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey);
  }

  /// Save theme mode.
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  /// Initial sample contacts to showcase full functionality.
  List<Contact> _getSampleContacts() {
    return [
      Contact(
        id: '1',
        name: 'Aman Sharma',
        phone: '+91 98765 43210',
        email: 'aman.sharma@example.com',
        category: 'Work',
        notes: 'Senior Flutter & Mobile Developer. Project Lead.',
        isFavorite: true,
        avatarColorIndex: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Contact(
        id: '2',
        name: 'Priya Patel',
        phone: '+91 91234 56789',
        email: 'priya.patel@designhub.io',
        category: 'Friends',
        notes: 'UI/UX Designer. Collaborated on multiple product designs.',
        isFavorite: true,
        avatarColorIndex: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Contact(
        id: '3',
        name: 'David Miller',
        phone: '+1 415-555-0199',
        email: 'david.miller@techcorp.com',
        category: 'Work',
        notes: 'Engineering Director at TechCorp.',
        isFavorite: false,
        avatarColorIndex: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Contact(
        id: '4',
        name: 'Dr. Elena Rostova',
        phone: '+44 20 7946 0958',
        email: 'elena.rostova@healthclinic.org',
        category: 'General',
        notes: 'Family physician. Clinic hours: Mon-Thu 9am-4pm.',
        isFavorite: false,
        avatarColorIndex: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Contact(
        id: '5',
        name: 'Sarah Connor',
        phone: '+1 310-555-0142',
        email: 'sarah.c@cyberdyne.net',
        category: 'Family',
        notes: 'Sister. Emergency contact.',
        isFavorite: true,
        avatarColorIndex: 6,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
