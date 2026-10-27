import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../widgets/contact_tile.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/qr_dialog.dart';
import '../widgets/search_bar_widget.dart';
import 'contact_detail_screen.dart';
import 'contact_form_screen.dart';
import 'submission_qr_screen.dart';

/// Main screen displaying the list of contacts with search, category filtering,
/// quick actions, theme toggle, and access to QR codes.
class ContactListScreen extends StatelessWidget {
  final ContactProvider provider;

  const ContactListScreen({
    super.key,
    required this.provider,
  });

  void _navigateToAddContact(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(provider: provider),
      ),
    );
  }

  void _navigateToContactDetail(BuildContext context, Contact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactDetailScreen(
          contact: contact,
          provider: provider,
        ),
      ),
    );
  }

  void _navigateToSubmissionQr(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubmissionQrScreen(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.contacts_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Contacts'),
            const SizedBox(width: 8),
            // Count pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${provider.totalCount}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Submission QR Code Button
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'Submission QR Code',
            onPressed: () => _navigateToSubmissionQr(context),
          ),

          // Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: provider.toggleTheme,
          ),

          // Popup Menu (Sample Data, Reset)
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == 'samples') {
                provider.resetToSamples();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sample demo contacts loaded!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (val == 'clear') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: const Text('Clear all contacts?'),
                    content: const Text(
                      'This will delete all stored contacts. You can reload sample contacts anytime.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          provider.clearAll();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All contacts cleared.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              } else if (val == 'submission') {
                _navigateToSubmissionQr(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'submission',
                child: Row(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Submission & QR Code'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'samples',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Load Sample Contacts'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Clear All Contacts', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Search and Filter Section
                ContactSearchBar(provider: provider),
                const SizedBox(height: 8),

                // Main Content
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filtered = provider.filteredContacts;

                      // Check if total contacts is 0
                      if (provider.totalCount == 0) {
                        return EmptyStateWidget(
                          isSearchEmpty: false,
                          onAddContact: () => _navigateToAddContact(context),
                          onLoadSamples: () => provider.resetToSamples(),
                        );
                      }

                      // Check if search/filter returned 0 results
                      if (filtered.isEmpty) {
                        return EmptyStateWidget(
                          isSearchEmpty: true,
                          searchQuery: provider.searchQuery,
                          onAddContact: () => _navigateToAddContact(context),
                          onClearSearch: () {
                            provider.clearSearch();
                            provider.setCategory('All');
                          },
                        );
                      }

                      // List of contacts
                      return RefreshIndicator(
                        onRefresh: () async {
                          // refresh contacts
                          await Future.delayed(const Duration(milliseconds: 300));
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4, bottom: 84),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final contact = filtered[index];
                            return ContactTile(
                              contact: contact,
                              onTap: () => _navigateToContactDetail(context, contact),
                              onToggleFavorite: () => provider.toggleFavorite(contact.id),
                              onQrCode: () => QrDialog.showContactQr(context, contact),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddContact(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
