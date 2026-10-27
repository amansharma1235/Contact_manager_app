import 'package:flutter/material.dart';
import '../providers/contact_provider.dart';

/// Reusable search bar widget with category filter chips and sort selector.
class ContactSearchBar extends StatefulWidget {
  final ContactProvider provider;

  const ContactSearchBar({
    super.key,
    required this.provider,
  });

  @override
  State<ContactSearchBar> createState() => _ContactSearchBarState();
}

class _ContactSearchBarState extends State<ContactSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.provider.searchQuery);
  }

  @override
  void didUpdateWidget(covariant ContactSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.searchQuery != _searchController.text) {
      _searchController.text = widget.provider.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: provider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search contacts by name, phone...',
                      hintStyle: TextStyle(
                        color: theme.hintColor.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Sort Menu
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: PopupMenuButton<ContactSortOption>(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort contacts',
                  initialValue: provider.sortOption,
                  onSelected: provider.setSortOption,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ContactSortOption.nameAsc,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 18),
                          SizedBox(width: 10),
                          Text('Name (A to Z)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ContactSortOption.nameDesc,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 18),
                          SizedBox(width: 10),
                          Text('Name (Z to A)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ContactSortOption.recentlyAdded,
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Recently Added'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: ContactProvider.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = ContactProvider.categories[index];
              final isSelected = provider.selectedCategory == cat;

              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    provider.setCategory(cat);
                  }
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                backgroundColor: theme.cardTheme.color,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withValues(alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              );
            },
          ),
        ),
      ],
    );
  }
}
