// ==============================================================================
// Nutrient Earth — In-App Notification Centre Sheet
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/communication/communication_models.dart';
import '../../../../core/services/communication/central_communication_engine.dart';

class InAppNotificationCentreSheet extends StatefulWidget {
  final String userId;
  final CentralCommunicationEngine communicationEngine;
  final void Function(String deepLink)? onNavigateDeepLink;

  const InAppNotificationCentreSheet({
    super.key,
    required this.userId,
    required this.communicationEngine,
    this.onNavigateDeepLink,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required CentralCommunicationEngine communicationEngine,
    void Function(String deepLink)? onNavigateDeepLink,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InAppNotificationCentreSheet(
        userId: userId,
        communicationEngine: communicationEngine,
        onNavigateDeepLink: onNavigateDeepLink,
      ),
    );
  }

  @override
  State<InAppNotificationCentreSheet> createState() =>
      _InAppNotificationCentreSheetState();
}

class _InAppNotificationCentreSheetState
    extends State<InAppNotificationCentreSheet> {
  List<InAppNotificationItem> _notifications = [];
  bool _isLoading = true;
  CommunicationCategory? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final items =
        await widget.communicationEngine.getInAppNotifications(widget.userId);
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  List<InAppNotificationItem> get _filteredNotifications {
    if (_selectedFilter == null) return _notifications;
    return _notifications
        .where((n) => n.category == _selectedFilter)
        .toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NETokens.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: NETokens.deepestForest,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: NETokens.botanicalTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_unreadCount new',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: NETokens.deepestForest),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Goals', CommunicationCategory.goalReminder),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Research', CommunicationCategory.researchDigest),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Security', CommunicationCategory.securityAlert),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Updates', CommunicationCategory.systemUpdate),
              ],
            ),
          ),
          const Divider(color: NETokens.surfaceDim, height: 16),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: NETokens.botanicalTeal,
                    ),
                  )
                : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _filteredNotifications.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: NETokens.surfaceDim, height: 12),
                        itemBuilder: (context, index) {
                          final item = _filteredNotifications[index];
                          return _buildNotificationTile(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CommunicationCategory? category) {
    final isSelected = _selectedFilter == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedFilter = category);
      },
      selectedColor: NETokens.paleMint,
      backgroundColor: NETokens.surface,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? NETokens.deepestForest : NETokens.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? NETokens.botanicalTeal : NETokens.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: NETokens.mutedSage,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: NETokens.deepestForest,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are completely up to date with your circadian rhythm, movement goals, and scientific digests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: NETokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(InAppNotificationItem item) {
    IconData iconData;
    Color iconColor;

    switch (item.category) {
      case CommunicationCategory.goalReminder:
        iconData = Icons.fitness_center_rounded;
        iconColor = NETokens.botanicalTeal;
        break;
      case CommunicationCategory.researchDigest:
        iconData = Icons.science_outlined;
        iconColor = NETokens.darkEvergreen;
        break;
      case CommunicationCategory.securityAlert:
        iconData = Icons.security_rounded;
        iconColor = Colors.red.shade700;
        break;
      case CommunicationCategory.accountExport:
        iconData = Icons.file_download_outlined;
        iconColor = NETokens.botanicalTeal;
        break;
      case CommunicationCategory.reEngagement:
        iconData = Icons.spa_outlined;
        iconColor = NETokens.mutedSage;
        break;
      case CommunicationCategory.systemUpdate:
        iconData = Icons.system_update_alt_rounded;
        iconColor = NETokens.forest;
        break;
    }

    return InkWell(
      onTap: () async {
        if (!item.isRead) {
          await widget.communicationEngine.markInAppAsRead(item.id);
          _loadNotifications();
        }
        if (item.deepLink != null && widget.onNavigateDeepLink != null) {
          widget.onNavigateDeepLink!(item.deepLink!);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.transparent : NETokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: item.isRead
              ? null
              : Border.all(color: NETokens.paleMint, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: NETokens.deepestForest,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: NETokens.botanicalTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: NETokens.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimestamp(item.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: NETokens.outline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.archive_outlined, size: 18),
              color: NETokens.outline,
              onPressed: () async {
                await widget.communicationEngine.archiveInApp(item.id);
                _loadNotifications();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
