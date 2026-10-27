import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/qr_dialog.dart';
import 'contact_form_screen.dart';

/// Screen displaying complete details of a selected contact with quick actions,
/// edit, delete, and vCard QR code generation.
class ContactDetailScreen extends StatefulWidget {
  final Contact contact;
  final ContactProvider provider;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.provider,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  void _copyToClipboard(String label, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editContact() async {
    final updated = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(
          contact: _contact,
          provider: widget.provider,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _contact = updated;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Delete Contact?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${_contact.name}? This action cannot be easily undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final deleted = await widget.provider.deleteContact(_contact.id);
      if (!mounted) return;

      Navigator.of(context).pop(); // Back to list screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact "${_contact.name}" deleted.'),
          behavior: SnackBarBehavior.floating,
          action: deleted != null
              ? SnackBarAction(
                  label: 'UNDO',
                  textColor: Colors.amberAccent,
                  onPressed: () {
                    widget.provider.restoreContact(deleted);
                  },
                )
              : null,
        ),
      );
    }
  }

  void _toggleFavorite() {
    widget.provider.toggleFavorite(_contact.id);
    setState(() {
      _contact = _contact.copyWith(isFavorite: !_contact.isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(
            icon: Icon(
              _contact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _contact.isFavorite ? AppTheme.warningColor : null,
              size: 26,
            ),
            tooltip: _contact.isFavorite ? 'Remove Favorite' : 'Mark Favorite',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'View QR Code',
            onPressed: () => QrDialog.showContactQr(context, _contact),
          ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == 'edit') _editContact();
              if (val == 'delete') _confirmDelete();
              if (val == 'qr') QrDialog.showContactQr(context, _contact);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Edit Contact'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Share QR Code'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.errorColor),
                    SizedBox(width: 10),
                    Text('Delete Contact', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'avatar_${_contact.id}',
                    child: ContactAvatar(
                      initials: _contact.initials,
                      colorIndex: _contact.avatarColorIndex,
                      radius: 50,
                      fontSize: 36,
                      showBadge: _contact.isFavorite,
                      badgeIcon: Icons.star,
                      badgeColor: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _contact.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _contact.category,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        onTap: () => _copyToClipboard('Phone number', _contact.phone),
                      ),
                      const SizedBox(width: 16),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.message_rounded,
                        label: 'Message',
                        onTap: () => _copyToClipboard('Phone number', _contact.phone),
                      ),
                      const SizedBox(width: 16),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.email_rounded,
                        label: 'Email',
                        onTap: () => _copyToClipboard('Email address', _contact.email),
                      ),
                      const SizedBox(width: 16),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.qr_code_rounded,
                        label: 'QR Code',
                        onTap: () => QrDialog.showContactQr(context, _contact),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detailed Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Phone Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone, color: Colors.green),
                      ),
                      title: const Text('Phone Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        _contact.phone,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copy Phone',
                        onPressed: () => _copyToClipboard('Phone number', _contact.phone),
                      ),
                    ),
                  ),

                  // Email Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.email, color: Colors.blue),
                      ),
                      title: const Text('Email Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        _contact.email,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copy Email',
                        onPressed: () => _copyToClipboard('Email address', _contact.email),
                      ),
                    ),
                  ),

                  // Notes Card (if present)
                  if (_contact.notes.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.note_alt_outlined, color: Colors.amber),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Notes', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _contact.notes,
                                    style: const TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Metadata Info (Date added / updated)
                  Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Added: ${dateFormat.format(_contact.createdAt)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.update_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Last updated: ${dateFormat.format(_contact.updatedAt)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons Row (Edit & Delete)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _editContact,
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Edit Contact'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
