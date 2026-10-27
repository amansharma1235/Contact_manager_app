import 'dart:convert';

/// Represents a Contact entity in the Contact Manager application.
class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String category;
  final String notes;
  final bool isFavorite;
  final int avatarColorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.category = 'General',
    this.notes = '',
    this.isFavorite = false,
    this.avatarColorIndex = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? category,
    String? notes,
    bool? isFavorite,
    int? avatarColorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'category': category,
      'notes': notes,
      'isFavorite': isFavorite,
      'avatarColorIndex': avatarColorIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      notes: map['notes'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      avatarColorIndex: map['avatarColorIndex'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Contact.fromJson(String source) =>
      Contact.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Returns initials from contact name (up to 2 letters).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Generates a standard vCard 3.0 string for seamless QR code scanning.
  String toVCard() {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$name');
    buffer.writeln('TEL;TYPE=CELL:$cleanPhone');
    buffer.writeln('EMAIL;TYPE=INTERNET:$email');
    if (category.isNotEmpty) {
      buffer.writeln('CATEGORIES:$category');
    }
    if (notes.isNotEmpty) {
      buffer.writeln('NOTE:$notes');
    }
    buffer.writeln('END:VCARD');
    return buffer.toString().trim();
  }
}
