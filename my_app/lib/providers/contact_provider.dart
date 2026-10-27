import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_storage_service.dart';

enum ContactSortOption {
  nameAsc,
  nameDesc,
  recentlyAdded,
}

/// Central state manager for contacts and app-level preferences.
class ContactProvider extends ChangeNotifier {
  final ContactStorageService _storageService = ContactStorageService();

  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showFavoritesOnly = false;
  ContactSortOption _sortOption = ContactSortOption.nameAsc;
  ThemeMode _themeMode = ThemeMode.system;

  // Getters
  List<Contact> get allContacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;
  ContactSortOption get sortOption => _sortOption;
  ThemeMode get themeMode => _themeMode;
  int get totalCount => _contacts.length;
  int get favoritesCount => _contacts.where((c) => c.isFavorite).length;

  /// Categories available for filtering
  static const List<String> categories = [
    'All',
    'Favorites',
    'Work',
    'Family',
    'Friends',
    'General',
  ];

  ContactProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load theme
    final isDark = await _storageService.loadDarkMode();
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    // Load contacts
    _contacts = await _storageService.loadContacts();
    _isLoading = false;
    notifyListeners();
  }

  /// Filtered and sorted contacts according to current search, category, and sort option.
  List<Contact> get filteredContacts {
    var result = List<Contact>.from(_contacts);

    // Filter by favorite
    if (_showFavoritesOnly || _selectedCategory == 'Favorites') {
      result = result.where((c) => c.isFavorite).toList();
    } else if (_selectedCategory != 'All') {
      result = result
          .where((c) =>
              c.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filter by search query (name, phone, email)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((c) {
        final nameMatch = c.name.toLowerCase().contains(query);
        final phoneMatch = c.phone.replaceAll(RegExp(r'\s+'), '').contains(query);
        final emailMatch = c.email.toLowerCase().contains(query);
        return nameMatch || phoneMatch || emailMatch;
      }).toList();
    }

    // Sort
    switch (_sortOption) {
      case ContactSortOption.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ContactSortOption.nameDesc:
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case ContactSortOption.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  /// Update search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query.
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Set category filter.
  void setCategory(String category) {
    _selectedCategory = category;
    if (category == 'Favorites') {
      _showFavoritesOnly = true;
    } else {
      _showFavoritesOnly = false;
    }
    notifyListeners();
  }

  /// Set sort option.
  void setSortOption(ContactSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Add new contact.
  Future<void> addContact(Contact contact) async {
    _contacts.insert(0, contact);
    await _storageService.saveContacts(_contacts);
    notifyListeners();
  }

  /// Update existing contact.
  Future<void> updateContact(Contact updated) async {
    final index = _contacts.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _contacts[index] = updated;
      await _storageService.saveContacts(_contacts);
      notifyListeners();
    }
  }

  /// Delete contact by ID.
  Future<Contact?> deleteContact(String id) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final removed = _contacts.removeAt(index);
      await _storageService.saveContacts(_contacts);
      notifyListeners();
      return removed;
    }
    return null;
  }

  /// Restore a deleted contact (Undo action).
  Future<void> restoreContact(Contact contact) async {
    _contacts.add(contact);
    await _storageService.saveContacts(_contacts);
    notifyListeners();
  }

  /// Toggle favorite status of a contact.
  Future<void> toggleFavorite(String id) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _contacts[index];
      _contacts[index] = current.copyWith(isFavorite: !current.isFavorite);
      await _storageService.saveContacts(_contacts);
      notifyListeners();
    }
  }

  /// Reset to sample contacts.
  Future<void> resetToSamples() async {
    _isLoading = true;
    notifyListeners();
    _contacts = await _storageService.resetToSamples();
    _searchQuery = '';
    _selectedCategory = 'All';
    _showFavoritesOnly = false;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear all contacts.
  Future<void> clearAll() async {
    _contacts.clear();
    await _storageService.clearAll();
    notifyListeners();
  }

  /// Toggle dark / light theme.
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await _storageService.saveDarkMode(false);
    } else {
      _themeMode = ThemeMode.dark;
      await _storageService.saveDarkMode(true);
    }
    notifyListeners();
  }

  /// Get contact by id.
  Contact? getContactById(String id) {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
