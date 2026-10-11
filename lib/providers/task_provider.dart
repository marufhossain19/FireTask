import 'dart:async';
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
  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  TaskFilter _currentFilter = TaskFilter.all;
  String _searchQuery = '';
  String? _selectedCourseBucket;
  TaskSortOption _sortOption = TaskSortOption.newest;
  TaskPriority? _selectedPriorityFilter;
  bool _isLoading = false;

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

  List<TaskModel> get allTasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  String? get selectedCourseBucket => _selectedCourseBucket;
  TaskSortOption get sortOption => _sortOption;
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

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

  Future<void> _loadFromLocalStorage(String userId) async {
    final localTasks = await LocalStorageService.loadTasks(userId);
    if (_currentUserId == userId && _tasks.isEmpty) {
      _tasks = localTasks;
      notifyListeners();
    }
  }

  void _listenToFirestore(String userId) {
    if (_firebaseService.isInitialized) {
      _tasksSubscription?.cancel();
      _tasksSubscription = _firebaseService.getTasksStream(userId).listen((firestoreTasks) {
        if (_currentUserId == userId) {
          final seenIds = <String>{};
          _tasks = firestoreTasks.where((t) => seenIds.add(t.id)).toList();
          LocalStorageService.saveTasks(_tasks, userId);
          notifyListeners();
        }
      });
    }
  }

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

  Future<void> addTask(TaskModel task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final taskWithUser = task.copyWith(userId: _currentUserId);
      if (_firebaseService.isInitialized && _currentUserId != null) {
        final docId = await _firebaseService.addTask(taskWithUser, _currentUserId);
        final newTask = docId != null ? taskWithUser.copyWith(id: docId) : taskWithUser;
        if (!_tasks.any((t) => t.id == newTask.id)) {
          _tasks.insert(0, newTask);
        }
        // Schedule priority-based reminder for new task
        NotificationService().scheduleTaskReminder(newTask);
      } else {
        if (!_tasks.any((t) => t.id == taskWithUser.id)) {
          _tasks.insert(0, taskWithUser);
        }
        // Schedule priority-based reminder for new task
        NotificationService().scheduleTaskReminder(taskWithUser);
      }
      // Ensure unique task IDs across _tasks
      final seenIds = <String>{};
      _tasks = _tasks.where((t) => seenIds.add(t.id)).toList();

      // Persist to local storage immediately
      if (_currentUserId != null) {
        await LocalStorageService.saveTasks(_tasks, _currentUserId!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized) {
        await _firebaseService.updateTask(task);
      }
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
      // Persist changes to local storage immediately
      if (_currentUserId != null) {
        await LocalStorageService.saveTasks(_tasks, _currentUserId!);
      }

      // Re-schedule reminder with updated time/priority
      await NotificationService().cancelScheduledReminder(task.id);
      if (!task.isCompleted) {
        NotificationService().scheduleTaskReminder(task);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updatedStatus = !_tasks[index].isCompleted;
      _tasks[index] = _tasks[index].copyWith(isCompleted: updatedStatus);
      notifyListeners();

      // Persist to local storage immediately
      if (_currentUserId != null) {
        await LocalStorageService.saveTasks(_tasks, _currentUserId!);
      }

      if (_firebaseService.isInitialized) {
        await _firebaseService.toggleTaskCompletion(id, updatedStatus);
      }

      // If marked completed, cancel the upcoming reminder; if uncompleted, re-schedule it
      if (updatedStatus) {
        NotificationService().cancelScheduledReminder(id);
      } else {
        NotificationService().scheduleTaskReminder(_tasks[index]);
      }
    }
  }

  Future<void> deleteTask(String id) async {
    // Cancel scheduled reminder for this task
    NotificationService().cancelScheduledReminder(id);

    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();

    // Persist to local storage immediately
    if (_currentUserId != null) {
      await LocalStorageService.saveTasks(_tasks, _currentUserId!);
    }

    if (_firebaseService.isInitialized) {
      await _firebaseService.deleteTask(id);
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
