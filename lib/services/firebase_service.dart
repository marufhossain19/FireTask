import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/task_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isFirebaseInitialized = false;

  bool get isInitialized => _isFirebaseInitialized;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

      // Enable Firestore offline persistence explicitly.
      // MUST be set before any Firestore read/write to take effect.
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isFirebaseInitialized = true;
    } catch (e) {
      // Firebase not configured yet (e.g. google-services.json pending)
      debugPrint('Firebase initialization failed: $e');
      _isFirebaseInitialized = false;
    }
  }

  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges =>
      _auth != null ? _auth!.authStateChanges() : Stream.value(null);

  // Firestore tasks collection reference
  CollectionReference<Map<String, dynamic>>? get _tasksCollection {
    if (_firestore == null) return null;
    return _firestore!.collection('tasks');
  }

  /// Generate a Firestore document ID without creating a document.
  /// This lets us assign the final ID before writing, preventing
  /// ID mismatches between optimistic local inserts and server documents.
  String? generateDocId() {
    return _tasksCollection?.doc().id;
  }

  /// Stream of tasks for a specific user, including snapshot metadata
  /// (`isFromCache`) for offline/online detection.
  ///
  /// Uses [includeMetadataChanges] so the stream fires when connectivity
  /// status changes (cache → server or vice-versa), allowing the UI to
  /// show/hide an offline banner without any extra packages.
  Stream<({List<TaskModel> tasks, bool isFromCache})> getTasksStreamWithMeta([String? userId]) {
    if (_tasksCollection == null) {
      return Stream.value((tasks: <TaskModel>[], isFromCache: true));
    }

    final targetUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : currentUser?.uid;

    if (targetUserId == null || targetUserId.isEmpty) {
      return Stream.value((tasks: <TaskModel>[], isFromCache: true));
    }

    return _tasksCollection!
        .where('userId', isEqualTo: targetUserId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return (tasks: list, isFromCache: snapshot.metadata.isFromCache);
    });
  }

  // Stream of tasks for a specific user (backward-compatible, no metadata)
  Stream<List<TaskModel>> getTasksStream([String? userId]) {
    return getTasksStreamWithMeta(userId).map((snapshot) => snapshot.tasks);
  }

  /// Write a task to Firestore using a pre-determined document ID.
  ///
  /// Uses `set()` instead of `add()` so the document ID matches the
  /// locally-assigned ID, eliminating the duplicate-task problem that
  /// occurs when optimistic inserts use one ID and Firestore generates
  /// a different one.
  Future<void> setTask(TaskModel task, [String? userId]) async {
    if (_tasksCollection == null) return;
    final data = task.toMap();
    final targetUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (task.userId != null && task.userId!.isNotEmpty)
            ? task.userId
            : currentUser?.uid;
    if (targetUserId != null && targetUserId.isNotEmpty) {
      data['userId'] = targetUserId;
    }
    await _tasksCollection!.doc(task.id).set(data);
  }

  // Add task to Firestore
  Future<String?> addTask(TaskModel task, [String? userId]) async {
    if (_tasksCollection == null) return null;
    final data = task.toMap();
    final targetUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (task.userId != null && task.userId!.isNotEmpty)
            ? task.userId
            : currentUser?.uid;
    if (targetUserId != null && targetUserId.isNotEmpty) {
      data['userId'] = targetUserId;
    }
    final docRef = await _tasksCollection!.add(data);
    return docRef.id;
  }

  // Update task in Firestore
  Future<void> updateTask(TaskModel task) async {
    if (_tasksCollection == null) return;
    final data = task.toMap();
    final targetUserId = (task.userId != null && task.userId!.isNotEmpty)
        ? task.userId
        : currentUser?.uid;
    if (targetUserId != null && targetUserId.isNotEmpty) {
      data['userId'] = targetUserId;
    }
    await _tasksCollection!.doc(task.id).update(data);
  }

  // Toggle complete
  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    if (_tasksCollection == null) return;
    await _tasksCollection!.doc(id).update({
      'isCompleted': isCompleted,
    });
  }

  // Delete task from Firestore
  Future<void> deleteTask(String id) async {
    if (_tasksCollection == null) return;
    await _tasksCollection!.doc(id).delete();
  }
}
