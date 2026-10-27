import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/app_theme.dart';
import 'contact_avatar.dart';

/// Modern card-based list item for displaying a contact in the list.
class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;
  final VoidCallback? onQrCode;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
    this.onQrCode,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF3B82F6); // Blue
      case 'family':
        return const Color(0xFFEC4899); // Pink
      case 'friends':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(contact.category);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar with Hero transition
              Hero(
                tag: 'avatar_${contact.id}',
                child: ContactAvatar(
                  initials: contact.initials,
                  colorIndex: contact.avatarColorIndex,
                  radius: 26,
                  showBadge: contact.isFavorite,
                  badgeIcon: Icons.star,
                  badgeColor: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 14),

              // Contact Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Category Badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            contact.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            contact.category,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Phone Number
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contact.phone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Email Address
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contact.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Star Action
              IconButton(
                icon: Icon(
                  contact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: contact.isFavorite ? AppTheme.warningColor : theme.iconTheme.color?.withValues(alpha: 0.4),
                  size: 24,
                ),
                tooltip: contact.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onPressed: onToggleFavorite,
              ),

              // Chevron forward
              Icon(
                Icons.chevron_right_rounded,
                color: theme.iconTheme.color?.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
