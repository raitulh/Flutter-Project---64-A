import 'package:flutter/material.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.icon = Icons.notifications_outlined,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isRead;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    IconData? icon,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({
    super.key,
    required this.notifications,
    required this.onClearAll,
    required this.onMarkAllAsRead,
    required this.onDismissItem,
  });

  final List<AppNotification> notifications;
  final VoidCallback onClearAll;
  final VoidCallback onMarkAllAsRead;
  final ValueChanged<String> onDismissItem;

  static Future<void> show(
    BuildContext context, {
    required List<AppNotification> notifications,
    required VoidCallback onClearAll,
    required VoidCallback onMarkAllAsRead,
    required ValueChanged<String> onDismissItem,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return NotificationSheet(
          notifications: notifications,
          onClearAll: onClearAll,
          onMarkAllAsRead: onMarkAllAsRead,
          onDismissItem: onDismissItem,
        );
      },
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AppNotification> items = widget.notifications;
    final int unreadCount = items.where((AppNotification n) => !n.isRead).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Notifications', style: theme.textTheme.titleLarge),
                      if (unreadCount > 0) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount new',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (items.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'Notification options',
                      onSelected: (String action) {
                        if (action == 'read') {
                          widget.onMarkAllAsRead();
                          setState(() {});
                        } else if (action == 'clear') {
                          widget.onClearAll();
                          setState(() {});
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'read',
                          child: Text('Mark all as read'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'clear',
                          child: Text('Clear all'),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No notifications',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "You're all caught up!",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: items.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int index) {
                          final AppNotification item = items[index];
                          return Dismissible(
                            key: ValueKey<String>(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            onDismissed: (_) {
                              widget.onDismissItem(item.id);
                              setState(() {});
                            },
                            child: Card(
                              color: item.isRead
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: item.isRead
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : theme.colorScheme.primaryContainer,
                                  foregroundColor: item.isRead
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onPrimaryContainer,
                                  child: Icon(item.icon, size: 20),
                                ),
                                title: Text(
                                  item.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: item.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(height: 4),
                                    Text(item.message),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.time,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
