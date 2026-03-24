import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
      NotificationScreen({super.key}); // ✅ FIXED (const added)

  final NotificationService service = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: () async {
              await service.markAllRead();
            },
          ),
        ],
      ),

      // 🔄 Pull to refresh
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },

        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: service.stream(),
          builder: (context, snap) {
            // 🔄 Loading
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ❌ Error
            if (snap.hasError) {
              return const Center(
                child: Text(
                  "Failed to load notifications",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final list = snap.data ?? [];

            // 📭 Empty state
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  "No notifications",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),

              itemBuilder: (context, i) {
                final n = list[i];

                final id = n['id'];
                final title = n['title']?.toString() ?? '';
                final body = n['body']?.toString() ?? '';
                final isRead = n['is_read'] == true;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  leading: Icon(
                    isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),

                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(body),

                  trailing: isRead
                      ? null
                      : const Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.red,
                        ),

                  // 👆 Mark as read
                  onTap: () async {
                    if (id != null) {
                      await service.markRead(id);
                    }
                  },

                  // 🗑 Delete notification
                  onLongPress: () async {
                    if (id != null) {
                      await service.delete(id);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}