// ==============================================================================
// Nutrient Earth — Authentic Daily Task Repository
// Manages genuine user daily plan tasks with Supabase persistence and RLS isolation.
// Strictly enforces zero fabricated tasks for fresh user accounts.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/supabase_config.dart';
import '../../features/today/state/today_state.dart';

abstract class TaskRepository {
  Future<List<DailyPlanTask>> getDailyTasks({String? userId});
  Future<DailyPlanTask?> createTask(DailyPlanTask task, {String? userId});
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted, {String? userId});
  Future<bool> deleteTask(String taskId, {String? userId});
}

class SupabaseTaskRepository implements TaskRepository {
  const SupabaseTaskRepository();

  @override
  Future<List<DailyPlanTask>> getDailyTasks({String? userId}) async {
    final client = SupabaseConfig.client;
    if (client == null) return const [];

    final targetUserId = userId ?? client.auth.currentUser?.id;
    if (targetUserId == null) return const [];

    try {
      final data = await client
          .from('user_daily_tasks')
          .select()
          .eq('user_id', targetUserId)
          .order('created_at', ascending: true);

      final list = (data as List<dynamic>?) ?? [];
      return list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return DailyPlanTask(
          id: map['id']?.toString() ?? '',
          title: map['title']?.toString() ?? '',
          note: map['note']?.toString() ?? '',
          timeString: map['scheduled_time']?.toString() ?? '',
          isCompleted: map['is_completed'] == true,
          isUpNext: map['is_up_next'] == true,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<DailyPlanTask?> createTask(DailyPlanTask task, {String? userId}) async {
    final client = SupabaseConfig.client;
    if (client == null) return null;

    final targetUserId = userId ?? client.auth.currentUser?.id;
    if (targetUserId == null) return null;

    try {
      final inserted = await client.from('user_daily_tasks').insert({
        'user_id': targetUserId,
        'title': task.title,
        'note': task.note,
        'scheduled_time': task.timeString,
        'is_completed': task.isCompleted,
        'is_up_next': task.isUpNext,
      }).select().maybeSingle();

      if (inserted != null) {
        final map = Map<String, dynamic>.from(inserted as Map);
        return DailyPlanTask(
          id: map['id']?.toString() ?? task.id,
          title: map['title']?.toString() ?? task.title,
          note: map['note']?.toString() ?? task.note,
          timeString: map['scheduled_time']?.toString() ?? task.timeString,
          isCompleted: map['is_completed'] == true,
          isUpNext: map['is_up_next'] == true,
        );
      }
      return task;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted, {String? userId}) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;

    final targetUserId = userId ?? client.auth.currentUser?.id;
    if (targetUserId == null) return false;

    try {
      await client
          .from('user_daily_tasks')
          .update({'is_completed': isCompleted, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', taskId)
          .eq('user_id', targetUserId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteTask(String taskId, {String? userId}) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;

    final targetUserId = userId ?? client.auth.currentUser?.id;
    if (targetUserId == null) return false;

    try {
      await client
          .from('user_daily_tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', targetUserId);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// In-memory implementation for isolated testing without live Supabase instances.
class InMemoryTaskRepository implements TaskRepository {
  final Map<String, List<DailyPlanTask>> _storage = {};

  InMemoryTaskRepository([Map<String, List<DailyPlanTask>>? initialData]) {
    if (initialData != null) {
      _storage.addAll(initialData);
    }
  }

  @override
  Future<List<DailyPlanTask>> getDailyTasks({String? userId}) async {
    final key = userId ?? 'default_user';
    return List.unmodifiable(_storage[key] ?? []);
  }

  @override
  Future<DailyPlanTask?> createTask(DailyPlanTask task, {String? userId}) async {
    final key = userId ?? 'default_user';
    _storage.putIfAbsent(key, () => []);
    _storage[key]!.add(task);
    return task;
  }

  @override
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted, {String? userId}) async {
    final key = userId ?? 'default_user';
    final tasks = _storage[key];
    if (tasks == null) return false;

    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return false;

    tasks[idx] = tasks[idx].copyWith(isCompleted: isCompleted);
    return true;
  }

  @override
  Future<bool> deleteTask(String taskId, {String? userId}) async {
    final key = userId ?? 'default_user';
    final tasks = _storage[key];
    if (tasks == null) return false;

    tasks.removeWhere((t) => t.id == taskId);
    return true;
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return const SupabaseTaskRepository();
});
