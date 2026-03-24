import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final SupabaseClient client = Supabase.instance.client;

  // ================= CURRENT USER =================
  String? get currentUserId => client.auth.currentUser?.id;

  // ================= CREATE TASK =================
  Future<void> createTask({
    required String title,
    String? description,
    required String assignedTo,
    String priority = 'medium',
    DateTime? deadline,
    String? fileUrl,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      debugPrint("❌ createTask: User not logged in");
      return;
    }

    try {
      await client.from('tasks').insert({
        'title': title.trim(),
        'description': description?.trim(),
        'assigned_to': assignedTo,
        'created_by': user.id,
        'status': 'pending',
        'priority': priority,
        'deadline': deadline?.toIso8601String(),
        'attachments': fileUrl != null ? [fileUrl] : [],
      });

      await _createNotification(
        userId: assignedTo,
        title: "New Task Assigned",
        body: title,
      );
    } on PostgrestException catch (e) {
      debugPrint("❌ DB ERROR (createTask): ${e.message}");
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR (createTask): $e");
    }
  }

  // ================= FILE UPLOAD =================
  Future<String?> uploadFile(PlatformFile file) async {
    try {
      final path =
          'tasks/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      final bytes =
          file.bytes ?? await File(file.path!).readAsBytes();

      await client.storage
          .from('task_files')
          .uploadBinary(path, bytes);

      return client.storage
          .from('task_files')
          .getPublicUrl(path);
    } catch (e) {
      debugPrint("❌ UPLOAD ERROR: $e");
      return null;
    }
  }

  // ================= ADD COMMENT =================
  Future<void> addComment(String id, String comment) async {
    if (comment.trim().isEmpty) return;

    try {
      final task = await client
          .from('tasks')
          .select('comments')
          .eq('id', id)
          .single();

      final list = List<String>.from(task['comments'] ?? []);
      list.add(comment.trim());

      await client
          .from('tasks')
          .update({'comments': list})
          .eq('id', id);
    } catch (e) {
      debugPrint("❌ ERROR (addComment): $e");
    }
  }

  // ================= ADD ATTACHMENT =================
  Future<void> addAttachment(String taskId, String fileUrl) async {
    try {
      final task = await client
          .from('tasks')
          .select('attachments')
          .eq('id', taskId)
          .single();

      final list = List<String>.from(task['attachments'] ?? []);
      list.add(fileUrl);

      await client.from('tasks').update({
        'attachments': list,
      }).eq('id', taskId);
    } catch (e) {
      debugPrint("❌ Attachment Error: $e");
    }
  }

  // ================= FETCH PAGINATED =================
  Future<List<Map<String, dynamic>>> fetchTasksPaginated({
    required int limit,
    required int offset,
    required String role,
    String? userId,
  }) async {
    try {
      var query = client.from('tasks').select();

      if (role == 'employee' && userId != null) {
        query = query.eq('assigned_to', userId);
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("❌ ERROR (fetchTasks): $e");
      return [];
    }
  }

  // ================= STREAM TASKS =================
  Stream<List<Map<String, dynamic>>> streamTasks({
    required String role,
  }) {
    final user = client.auth.currentUser;

    try {
      final stream = client
          .from('tasks')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false);

      if (role == 'employee' && user != null) {
        return stream.map((tasks) => tasks
            .where((t) => t['assigned_to'] == user.id)
            .toList());
      }

      return stream;
    } catch (e) {
      debugPrint("❌ STREAM ERROR: $e");
      return const Stream.empty();
    }
  }

  // ================= UPDATE STATUS =================
  Future<void> updateStatus({
    required String id,
    required String status,
    String? assignedTo,
  }) async {
    try {
      await client
          .from('tasks')
          .update({'status': status})
          .eq('id', id);

      if (assignedTo != null && assignedTo.isNotEmpty) {
        await _createNotification(
          userId: assignedTo,
          title: "Task Updated",
          body: "Status changed to $status",
        );
      }
    } catch (e) {
      debugPrint("❌ ERROR (updateStatus): $e");
    }
  }

  // ================= UPDATE PRIORITY =================
  Future<void> updatePriority({
    required String id,
    required String priority,
  }) async {
    try {
      await client
          .from('tasks')
          .update({'priority': priority})
          .eq('id', id);
    } catch (e) {
      debugPrint("❌ ERROR (updatePriority): $e");
    }
  }

  // ================= UPDATE DEADLINE =================
  Future<void> updateDeadline({
    required String id,
    required DateTime deadline,
  }) async {
    try {
      await client.from('tasks').update({
        'deadline': deadline.toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      debugPrint("❌ ERROR (updateDeadline): $e");
    }
  }

  // ================= DELETE =================
  Future<void> deleteTask(String id) async {
    try {
      await client.from('tasks').delete().eq('id', id);
    } catch (e) {
      debugPrint("❌ ERROR (deleteTask): $e");
    }
  }

  // ================= PRIVATE: NOTIFICATION =================
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      if (userId.isEmpty) return;

      await client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'is_read': false,
      });
    } catch (e) {
      debugPrint("❌ Notification Error: $e");
    }
  }
}