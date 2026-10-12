import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

enum TaskFilter { all, pending, completed }
enum TaskSortOption { dueDate, priority, newest }

class TaskProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<TaskModel> _tasks = [];
  String? _currentUserId;
  StreamSubscription? _tasksSubscription;
  TaskFilter _currentFilter = TaskFilter.all;
  String _searchQuery = '';
  String? _selectedCourseBucket;
  TaskSortOption _sortOption = TaskSortOption.newest;
  TaskPriority? _selectedPriorityFilter;
  bool _isLoading = false;

  /// Whether the latest Firestore snapshot was served from local cache
  /// (i.e. device is offline or server hasn't confirmed yet).
  /// Defaults to `true` until a server-confirmed snapshot arrives.
  bool _isOffline = true;

  TaskProvider([String? initialUserId]) {
    if (initialUserId != null && initialUserId.isNotEmpty) {
      updateCurrentUser(initialUserId);
    } else {
      final currentUid = _firebaseService.currentUser?.uid;
      if (currentUid != null && currentUid.isNotEmpty) {
        updateCurrentUser(currentUid);
      }
    }
  }

  void updateCurrentUser(String? userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    _tasksSubscription?.cancel();
    _tasks = [];
    notifyListeners();

    if (userId != null && userId.isNotEmpty) {
      _loadFromLocalStorage(userId);
      _listenToFirestore(userId);
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────

  List<TaskModel> get allTasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  String? get selectedCourseBucket => _selectedCourseBucket;
  TaskSortOption get sortOption => _sortOption;
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  /// Returns `true` when the device appears to be offline.
  /// For non-Firestore mode (guest), always returns `false` to avoid
  /// showing a misleading offline banner.
  bool get isOffline {
    if (!_firebaseService.isInitialized) return false;
    return _isOffline;
  }

  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  int countForCategory(String? category) {
    if (category == null) return _tasks.length;
    return _tasks.where((t) => t.category == category).length;
  }

  List<TaskModel> get filteredTasks {
    final list = _tasks.where((task) {
      // Filter by status
      if (_currentFilter == TaskFilter.pending && task.isCompleted) {
        return false;
      }
      if (_currentFilter == TaskFilter.completed && !task.isCompleted) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        final matchCourse = task.courseBucket.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCourse) return false;
      }

      // Filter by category
      if (_selectedCourseBucket != null && _selectedCourseBucket!.isNotEmpty) {
        if (task.courseBucket != _selectedCourseBucket) return false;
      }

      // Filter by priority
      if (_selectedPriorityFilter != null) {
        if (task.priority != _selectedPriorityFilter) return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortOption) {
      case TaskSortOption.dueDate:
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSortOption.priority:
        int score(TaskPriority p) => p == TaskPriority.high ? 2 : (p == TaskPriority.medium ? 1 : 0);
        list.sort((a, b) => score(b.priority).compareTo(score(a.priority)));
        break;
      case TaskSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }

  // ── Local Storage ────────────────────────────────────────────────────

  Future<void> _loadFromLocalStorage(String userId) async {
    _isLoading = true;
    try {
      final localTasks = await LocalStorageService.loadTasks(userId);
      if (_currentUserId == userId && _tasks.isEmpty) {
        _tasks = localTasks;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Persist current in-memory task list to SharedPreferences.
  void _saveToLocalStorage() {
    if (_currentUserId != null) {
      LocalStorageService.saveTasks(_tasks, _currentUserId!);
    }
  }

  // ── Firestore Stream ────────────────────────────────────────────────

  void _listenToFirestore(String userId) {
    if (!_firebaseService.isInitialized) return;

    _tasksSubscription?.cancel();
    _tasksSubscription = _firebaseService
        .getTasksStreamWithMeta(userId)
        .listen(
      (snapshot) {
        if (_currentUserId != userId) return;

        _isOffline = snapshot.isFromCache;

        // Firestore (including its local cache) is the source of truth.
        // Replace the in-memory list entirely to avoid stale/duplicate entries.
        _tasks = snapshot.tasks;
        LocalStorageService.saveTasks(_tasks, userId);
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Firestore stream error: $error');
        // Keep showing cached data — don't clear _tasks on transient errors.
        _isOffline = true;
        notifyListeners();
      },
    );
  }

  // ── Filters & Sorting ────────────────────────────────────────────────

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCourseBucketFilter(String? course) {
    _selectedCourseBucket = course;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCourseBucket = category;
    notifyListeners();
  }
  String? get selectedCategory => _selectedCourseBucket;

  void setSortOption(TaskSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCourseBucket = null;
    _selectedPriorityFilter = null;
    _sortOption = TaskSortOption.newest;
    notifyListeners();
  }

  // ── CRUD Operations (Optimistic + Fire-and-Forget) ───────────────────
  //
  // Every write follows the same pattern:
  //   1. Update local _tasks immediately → instant UI feedback.
  //   2. Persist to SharedPreferences → survives app restart.
  //   3. Fire-and-forget to Firestore → no await, never blocks the UI.
  //      Firestore's local cache absorbs the write instantly; the SDK
  //      syncs to the server whenever connectivity is available.
  //      The stream listener reconciles the authoritative state.

  /// Add a new task.
  ///
  /// Pre-generates a Firestore doc ID so the optimistic local insert and
  /// the Firestore document share the same identity — no duplicates.
  Future<void> addTask(TaskModel task) async {
    // Generate a stable ID that Firestore will use as the doc path
    final String taskId;
    if (_firebaseService.isInitialized) {
      taskId = _firebaseService.generateDocId() ??
          DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      taskId = task.id.isNotEmpty
          ? task.id
          : DateTime.now().millisecondsSinceEpoch.toString();
    }

    final finalTask = task.copyWith(id: taskId, userId: _currentUserId);

    // 1. Optimistic local insert
    _tasks.insert(0, finalTask);
    notifyListeners();

    // 2. Persist to local storage
    _saveToLocalStorage();

    // 3. Fire-and-forget to Firestore (uses set() with pre-generated ID)
    if (_firebaseService.isInitialized && _currentUserId != null) {
      _firebaseService.setTask(finalTask, _currentUserId).catchError((e) {
        debugPrint('⚠️ Firestore addTask error: $e');
        // Data is safe in Firestore's local cache — will retry when online.
      });
    }

    // 4. Schedule notification (guarded)
    _scheduleNotificationSafe(finalTask);
  }

  /// Update an existing task with optimistic local update.
  Future<void> updateTask(TaskModel task) async {
    // 1. Optimistic local update
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    notifyListeners();

    // 2. Persist to local storage
    _saveToLocalStorage();

    // 3. Fire-and-forget to Firestore
    if (_firebaseService.isInitialized) {
      _firebaseService.updateTask(task).catchError((e) {
        debugPrint('⚠️ Firestore updateTask error: $e');
      });
    }

    // 4. Re-schedule notification
    try {
      await NotificationService().cancelScheduledReminder(task.id);
      if (!task.isCompleted) {
        _scheduleNotificationSafe(task);
      }
    } catch (_) {}
  }

  /// Toggle task completion with optimistic local update.
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final updatedStatus = !_tasks[index].isCompleted;

    // 1. Optimistic local update
    _tasks[index] = _tasks[index].copyWith(isCompleted: updatedStatus);
    notifyListeners();

    // 2. Persist to local storage
    _saveToLocalStorage();

    // 3. Fire-and-forget to Firestore
    if (_firebaseService.isInitialized) {
      _firebaseService.toggleTaskCompletion(id, updatedStatus).catchError((e) {
        debugPrint('⚠️ Firestore toggleCompletion error: $e');
      });
    }

    // 4. Manage notifications
    try {
      if (updatedStatus) {
        NotificationService().cancelScheduledReminder(id);
      } else {
        _scheduleNotificationSafe(_tasks[index]);
      }
    } catch (_) {}
  }

  /// Delete a task with optimistic local removal.
  Future<void> deleteTask(String id) async {
    // 1. Cancel notification
    try {
      NotificationService().cancelScheduledReminder(id);
    } catch (_) {}

    // 2. Optimistic local delete
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();

    // 3. Persist to local storage
    _saveToLocalStorage();

    // 4. Fire-and-forget to Firestore
    if (_firebaseService.isInitialized) {
      _firebaseService.deleteTask(id).catchError((e) {
        debugPrint('⚠️ Firestore deleteTask error: $e');
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Schedule a notification without crashing if the service isn't ready.
  void _scheduleNotificationSafe(TaskModel task) {
    try {
      if (NotificationService().isInitialized) {
        NotificationService().scheduleTaskReminder(task);
      }
    } catch (e) {
      debugPrint('⚠️ Notification scheduling error: $e');
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
