import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/qr_dialog.dart';

/// Screen for adding a new contact or editing an existing one.
class ContactFormScreen extends StatefulWidget {
  final Contact? contact; // null if adding new
  final ContactProvider provider;

  const ContactFormScreen({
    super.key,
    this.contact,
    required this.provider,
  });

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;

  late String _selectedCategory;
  late bool _isFavorite;
  late int _selectedColorIndex;
  bool _isSaving = false;
  bool _autoValidate = false;

  bool get isEditing => widget.contact != null;

  final List<String> _categories = ['General', 'Work', 'Family', 'Friends'];

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');

    _selectedCategory = c?.category ?? 'General';
    _isFavorite = c?.isFavorite ?? false;
    _selectedColorIndex = c?.avatarColorIndex ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getInitials() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _saveContact() async {
    setState(() {
      _autoValidate = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final notes = _notesController.text.trim();

    final Contact savedContact;
    if (isEditing) {
      savedContact = widget.contact!.copyWith(
        name: name,
        phone: phone,
        email: email,
        category: _selectedCategory,
        notes: notes,
        isFavorite: _isFavorite,
        avatarColorIndex: _selectedColorIndex,
      );
      await widget.provider.updateContact(savedContact);
    } else {
      savedContact = Contact(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        email: email,
        category: _selectedCategory,
        notes: notes,
        isFavorite: _isFavorite,
        avatarColorIndex: _selectedColorIndex,
      );
      await widget.provider.addContact(savedContact);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    // Show instant success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Contact "${savedContact.name}" updated successfully!'
              : 'Contact "${savedContact.name}" added successfully!',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.successColor,
        action: SnackBarAction(
          label: 'View QR',
          textColor: Colors.white,
          onPressed: () {
            QrDialog.showContactQr(context, savedContact);
          },
        ),
      ),
    );

    // Prompt option to view generated QR code on submission as requested
    Navigator.of(context).pop(savedContact);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'New Contact'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveContact,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Live Avatar Preview with color chooser
              Center(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _nameController,
                      builder: (context, _, child) {
                        return ContactAvatar(
                          initials: _getInitials(),
                          colorIndex: _selectedColorIndex,
                          radius: 46,
                          fontSize: 32,
                          showBadge: _isFavorite,
                          badgeIcon: Icons.star,
                          badgeColor: AppTheme.warningColor,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose Avatar Color',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Color selection dots
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(AppTheme.avatarColors.length, (index) {
                        final color = AppTheme.getAvatarColor(index);
                        final isSelected = _selectedColorIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColorIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.6),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Form fields card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          hintText: 'e.g. Aman Sharma',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: Validators.validateName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),

                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: 'e.g. +91 98765 43210',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: Validators.validatePhone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'e.g. aman@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.validateEmail,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Notes Field
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add an address, work role, or relationship note...',
                          prefixIcon: Icon(Icons.notes_rounded),
                          alignLabelWithHint: true,
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),

                      // Favorite Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Mark as Favorite',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Keep this contact at quick access',
                          style: TextStyle(fontSize: 13),
                        ),
                        secondary: Icon(
                          _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: _isFavorite ? AppTheme.warningColor : null,
                        ),
                        value: _isFavorite,
                        onChanged: (val) {
                          setState(() {
                            _isFavorite = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Big Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveContact,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Contact & Generate QR',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
