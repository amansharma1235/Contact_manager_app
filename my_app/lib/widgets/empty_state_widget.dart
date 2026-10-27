import 'package:flutter/material.dart';

/// Reusable widget for empty lists, whether no contacts exist or no search results match.
class EmptyStateWidget extends StatelessWidget {
  final bool isSearchEmpty;
  final String searchQuery;
  final VoidCallback onAddContact;
  final VoidCallback? onClearSearch;
  final VoidCallback? onLoadSamples;

  const EmptyStateWidget({
    super.key,
    required this.isSearchEmpty,
    this.searchQuery = '',
    required this.onAddContact,
    this.onClearSearch,
    this.onLoadSamples,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSearchEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 44,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No contacts found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchQuery.isNotEmpty
                    ? 'No results found for "$searchQuery". Check spelling or clear your filters.'
                    : 'No contacts match the selected category.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              if (onClearSearch != null)
                OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset Search & Filters'),
                ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Contacts Available',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your contact list is currently empty. Start organizing your address book by adding your first contact!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAddContact,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add First Contact'),
            ),
            if (onLoadSamples != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onLoadSamples,
                icon: const Icon(Icons.cloud_download_outlined, size: 18),
                label: const Text('Load Demo Sample Contacts'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
